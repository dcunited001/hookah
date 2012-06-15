require "hookah/version"

module Hookah
  def self.included(base)
    set_method_names
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
    Proc.send(:include, ProcMethods) unless Proc.included_modules.include? ProcMethods
  end

  @@config = {
    add_callback_name: :add_callback,
    run_callback_name: :run_callback,
    run_proc_callback_name: :run_callback }

  def self.setup &block
    yield block, self
  end

  def self.set_method_names
    set_run_callback_method(run_callback_name)
    set_add_callback_method(add_callback_name)
    set_run_proc_callback_method(run_proc_callback_name)
  end

  module ProcMethods; end
  module InstanceMethods; end
  module ClassMethods; end

  def self.set_add_callback_method(method_name)
    ClassMethods.send(:define_method, method_name) do |callback_method, &block|
      #def add_callback(callback_method, *args, &block)
        define_method(callback_method) do |*args|
          block.call(*args)
        end
      #end
    end
  end

  def self.set_run_callback_method(method_name)
    InstanceMethods.send(:define_method, method_name) do |*args, &block|
      #def run_callback(*args, &block)
        callback = args.shift
        raise "Callback Name Required" unless callback
        #puts "#{block.nil?} -- #{block_given?}"
        return self.send(callback, *args) if block.nil?
        block.run_callback(callback, self, *args)
      #end
    end
  end

  def self.set_run_proc_callback_method(method_name)
    # http://www.mattsears.com/articles/2011/11/27/ruby-blocks-as-dynamic-callbacks
    ProcMethods.send(:define_method, method_name) do |callable, *args|
      #def run_callback(callable, *args)
        self === Class.new do # === is Proc alias for call
          method_name = callable.to_sym
          define_method(method_name) { |&block| block.nil? ? true : block.call(*args) }
          define_method("#{method_name}?") { true }
          def method_missing(method_name, *args, &block) false; end
        end.new
      #end
    end
  end

  def self.method_missing(method, *args, &block)
    setter = method.to_s.gsub(/=$/, '').to_sym if method.to_s =~ /=$/

    val = case
      when (@@config.keys.include?(method)) then @@config[method]
      when (setter and @@config.keys.include?(setter)) then @@config[setter] = args.first
    end

    val || super
  end
end

