# frozen_string_literal: true

require "test_helper"

class ReporterTest < Minitest::Test
  def setup
    @reporter = Loupe::Reporter.new
    @test = MyTest.new(Loupe::Reporter.new, :test_example)
  end

  def test_increment_test_count
    reporter = Loupe::Reporter.new

    assert_equal 0, reporter.instance_variable_get(:@test_count)
    assert_equal 1, reporter.increment_test_count
  end

  def test_increment_expectation_count
    reporter = Loupe::Reporter.new

    assert_equal 0, reporter.instance_variable_get(:@expectation_count)
    assert_equal 1, reporter.increment_expectation_count
  end

  def test_increment_success_count
    reporter = Loupe::Reporter.new
    reporter.expects(:print).with(".")

    assert_equal 0, reporter.instance_variable_get(:@success_count)
    assert_equal 1, reporter.increment_success_count
  end

  def test_increment_failure_count
    reporter = Loupe::Reporter.new
    reporter.expects(:print).with("F")

    assert_equal 1, reporter.increment_failure_count(@test, "Expected false to be truthy.")
    assert_equal 1, reporter.instance_variable_get(:@failures).length
  end

  def test_concatenation_operator
    reporter = Loupe::Reporter.new
    reporter.expects(:print).with(".")
    second_reporter = Loupe::Reporter.new

    reporter.increment_success_count
    second_reporter.increment_expectation_count
    reporter << second_reporter

    assert_equal 1, reporter.expectation_count
    assert_equal 1, reporter.success_count
  end

  def test_exit_status
    reporter = Loupe::Reporter.new
    reporter.expects(:print).with("F")

    assert_equal 0, reporter.exit_status
    reporter.increment_failure_count(@test, "Expected false to be truthy.")
    assert_equal 1, reporter.exit_status
  end
end
