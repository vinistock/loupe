# frozen_string_literal: true

require_relative "test_helper"

class SmokeTest < Guava::TestCase # :nodoc:
  def test_smoke_on_the_water
    assert_equal 123, Smoke.new.on_the_water
  end

  def test_some_failing_test
    assert_equal 321, Smoke.new.on_the_water
  end
end
