require 'spec_helper'

class TestClass; include Hookah; end
class TestClass2; end

class TestCallbacks
  include Hookah

  add_callback(:before_foo) {|*args| args.count}
  add_callback(:after_foo) {|*args| args.count}
  add_callback(:before_bar) {|*args| args.count}
  add_callback(:after_bar) {|*args| args.count}
  
  def foo(*args, &block)
    run_callback(:before_foo, *args, &block)
    foo = 'foo'
    run_callback(:after_foo, *args, &block)
    return foo
  end

  def bar(*args, &block)
    run_callback(:before_bar, *args, &block)
    bar = 'bar'
    run_callback(:after_bar, *args, &block)
    return 'bar'
  end

  def test_before_bar(*args)
    
  end

  def test_after_bar(*args)

  end
end

describe Hookah do
  describe "Module Loading:" do
    it "should load class and instance methods, as well as the proc methods" do
      TestClass.instance_methods.must_include :run_callback
      TestClass.methods.must_include :add_callback
      Proc.instance_methods.must_include :run_callback
    end

    it "should only load proc methods if necessary" do
      Proc.expects(:include).with(Hookah::ProcMethods).never
      TestClass.send(:include, Hookah)
    end
  end

  describe "Callback Method Names:" do
    it "should allow different method names" do
      Hookah.add_callback_name = :add_shesha
      Hookah.run_callback_name = :run_shesha
      #Hookah.run_proc_callback_name = :run_proc_shesha
      Hookah.add_callback_name.must_equal :add_shesha
      Hookah.run_callback_name.must_equal :run_shesha
      #Hookah.run_proc_callback_name.must_equal :run_proc_shesha
    end
    after do
      Hookah.add_callback_name = :add_callback
      Hookah.run_callback_name = :run_callback
      Hookah.run_proc_callback_name = :run_callback
    end
  end
  
  describe "#add_callback" do
    it "should add a callback method with the block passed" do
      TestCallbacks.send(:add_callback, :baz) { |*args| args.count }
      TestCallbacks.new.baz(1,2,3).must_equal 3
      TestCallbacks.new.baz.must_equal 0
    end
  end

  describe "#run_callback" do
    subject { TestCallbacks.new }
    it "should run a callback method if it exists" do
      subject.expects(:before_foo)
      subject.expects(:after_foo)
      subject.foo
    end

    it "should pass args to the callbacks" do
      subject.expects(:before_foo).with(1,2,3)
      subject.expects(:after_foo).with(1,2,3)
      subject.foo(1,2,3)
    end

    it "should override the callback method with a callback specified in the block" do
      subject.expects(:test_before_bar)
      subject.expects(:test_after_bar)
      subject.bar do |on|
        on.before_bar { |this, *args| this.test_before_bar(*args) }
        on.after_bar { |this, *args| this.test_after_bar(*args) }
      end
    end

    it "should default to the callback methods when a callback block is not specified" do
      skip "for now you must either use the defined callback methods or write all callbacks in the block.  you can delegate the block callbacks back to the object"

      subject.expects(:test_before_bar)
      subject.expects(:after_bar)
      subject.bar do |on|
        on.before_bar { |this, *args| this.test_before_bar(*args) }
      end
    end

    it "should pass the subject and args to the callbacks defined in the block" do
      subject.expects(:test_before_bar).with(1,2,3)
      subject.expects(:test_after_bar).with(1,2,3)
      subject.bar(1,2,3) do |on|
        on.before_bar { |this, *args| this.test_before_bar(*args) } 
        on.after_bar { |this, *args| this.test_after_bar(*args) }
      end
    end
  end
end

