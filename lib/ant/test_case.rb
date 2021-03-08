# typed: true
# frozen_string_literal: true

module Ant
  # TestCase
  #
  # The parent class for tests. Tests should
  # inherit from this class in order to be run.
  class TestCase
    class AssertionFailed < StandardError; end

    class << self
      def classes
        @classes ||= []
      end
    end

    def self.inherited(test_class)
      classes << test_class
      super
    end

    def self.run
      reporter = Reporter.new

      instance_methods
        .grep(/^test_.*/)
        .each do |method_name|
        new(reporter, method_name).run
      rescue AssertionFailed
        next
      end

      reporter
    end

    def initialize(reporter, method_name)
      @reporter = reporter
      @name = "\033[1;33m#{method_name}\033[0m"
      @method = method(method_name)
      @file, @line_number = @method.source_location
    end

    def setup; end

    def teardown; end

    def run
      @reporter.increment_test_count
      setup
      @method.call
      teardown
      @reporter.increment_success_count
    end

    def assert(actual, failure_message = nil)
      @reporter.increment_assertion_count
      return if actual

      failure_message ||= "Expected \033[1;31m#{actual}\033[0m to be \033[1;32mtruthy\033[0m."

      @reporter.increment_failure_count(
        @file,
        @name,
        @line_number,
        failure_message
      )

      raise AssertionFailed
    end

    def assert_equal(expected, actual, failure_message = nil)
      failure_message ||= "Expected \033[1;31m#{actual}\033[0m to be equal to \033[1;32m#{expected}\033[0m."
      assert(expected == actual, failure_message)
    end
  end
end
