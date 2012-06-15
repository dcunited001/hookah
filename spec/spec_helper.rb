# encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))

gem "minitest"
require "minitest/spec"
require "minitest/autorun"
require "minitest/matchers"
require "minitest/pride"
require "mocha"
require "pry"

require "hookah"

def this
  Hookah
end

