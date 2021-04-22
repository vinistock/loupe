# frozen_string_literal: true

require "active_support"
require "active_support/test_case"
require "active_support/testing/autorun"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
  end
end

class ParallelTest < ActiveSupport::TestCase
  def setup
    @number = 0
  end

  def test_number
    assert_equal 0, @number
  end

  def test_failing_test
    refute_equal 0, 0 % 500
  end

  def test_the_truth
    assert true
  end

  def test_the_truth2
    assert true
  end
end
