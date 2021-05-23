# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "guava"
require "minitest/autorun"
require "purdytest"
require "mocha/minitest"
require "byebug"

class MyTest < Guava::Test
  def test_example
    assert true
  end
end
