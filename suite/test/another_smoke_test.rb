# frozen_string_literal: true

require_relative "test_helper"

class AnotherSmokeTest < Guava::Test # :nodoc:
  def test_smoking
    assert_equal 321, Smoke.new.smoking
  end
end
