# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "guava"
require "minitest/autorun"
require "purdytest"
require "mocha/minitest"
require "byebug"

class MyTest < Guava::TestCase
  def test_example
    assert true
  end
end

def assert_assertion(name, success_args, failure_args, message)
  define_method("test_#{name}_success") do
    Guava::TestCase.any_instance.expects(:assert).with do |equal, msg|
      equal && message.match?(msg)
    end

    @test.send(name, *success_args)
  end

  define_method("test_#{name}_failure") do
    Guava::TestCase.any_instance.expects(:assert).with do |equal, msg|
      !equal && message.match?(msg)
    end

    @test.send(name, *failure_args)
  end
end

def assert_refute(name, success_args, failure_args, message)
  define_method("test_#{name}_success") do
    Guava::TestCase.any_instance.expects(:refute).with do |equal, msg|
      !equal && message.match?(msg)
    end

    @test.send(name, *success_args)
  end

  define_method("test_#{name}_failure") do
    Guava::TestCase.any_instance.expects(:refute).with do |equal, msg|
      equal && message.match?(msg)
    end

    @test.send(name, *failure_args)
  end
end
