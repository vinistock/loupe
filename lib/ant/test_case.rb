# typed: false
# frozen_string_literal: true

module Ant
  # TestCase
  #
  # The parent class for tests. Tests should
  # inherit from this class in order to be run.
  class TestCase # rubocop:disable Metrics/ClassLength
    class AssertionFailed < StandardError; end

    def self.classes
      @classes ||= {}
    end

    def self.add_line_number(number)
      classes[@current_class] << number
    end

    def self.inherited(test_class)
      @current_class = test_class
      classes[test_class] = []
      super
    end

    def self.run(line_numbers = [])
      reporter = Reporter.new
      test_methods = instance_methods.grep(/^test_.*/)

      unless line_numbers.empty?
        test_methods.select! do |method_name|
          line_numbers.include?(instance_method(method_name).source_location&.last.to_s)
        end
      end

      test_methods.each do |method_name|
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

    def assert_empty(actual, failure_message = nil)
      failure_message ||= "Expected \033[1;31m#{actual}\033[0m to be empty."
      assert(actual.empty?, failure_message)
    end

    def assert_respond_to(object, method, failure_message = nil)
      failure_message ||= "Expected \033[1;32m#{object}\033[0m to respond to \033[1;32m#{method}\033[0m."
      assert(object.respond_to?(method.to_sym), failure_message)
    end

    def assert_includes(collection, object, failure_message = nil)
      failure_message ||= "Expected \033[1;32m#{collection}\033[0m to include \033[1;32m#{object}\033[0m."
      assert(collection.include?(object), failure_message)
    end

    def assert_nil(actual, failure_message = nil)
      failure_message ||= "Expected \033[1;32m#{actual}\033[0m to be nil."
      assert(actual.nil?, failure_message)
    end

    def assert_instance_of(klass, object, failure_message = nil)
      failure_message ||= "Expected \033[1;32m#{object}\033[0m to be an instance of \033[1;31m#{klass}\033[0m, " \
        "not \033[1;32m#{object.class}\033[0m."

      assert(object.instance_of?(klass), failure_message)
    end

    def assert_kind_of(klass, object, failure_message = nil)
      failure_message ||= "Expected \033[1;32m#{object}\033[0m to be a kind of \033[1;31m#{klass}\033[0m, " \
        "not \033[1;32m#{object.class}\033[0m."

      assert(object.is_a?(klass), failure_message)
    end

    def assert_predicate(object, method, failure_message = nil)
      failure_message ||= "Expected \033[1;32m#{object}\033[0m to be \033[1;31m#{method}\033[0m."
      assert(object.public_send(method), failure_message)
    end

    def assert_match(matcher, object, failure_message = nil)
      failure_message ||= "Expected \033[1;31m#{matcher}\033[0m to match \033[1;32m#{object}\033[0m."
      assert_respond_to(matcher, :=~)

      matcher = Regexp.new(Regexp.escape(matcher)) if matcher.is_a?(String)
      assert(matcher =~ object, failure_message)
    end

    def assert_same(expected, actual, failure_message = nil)
      failure_message ||= "Expected \033[1;32m#{expected} (#{expected.object_id})\033[0m to be the same as " \
        "\033[1;32m#{actual} (#{actual.object_id})\033[0m."

      assert(expected.equal?(actual), failure_message)
    end

    def assert_path_exists(path, failure_message = nil)
      failure_message ||= "Expected path \033[1;32m'#{path}'\033[0m to exist."
      assert(File.exist?(path), failure_message)
    end

    def assert_in_delta(expected, actual, delta = 0.001, failure_message = nil)
      difference = (expected - actual).abs
      failure_message ||= "Expected |#{expected} - #{actual}| " \
        "\033[1;32m(#{difference})\033[0m to be <= \033[1;32m#{delta}\033[0m."

      assert(delta >= difference, failure_message)
    end

    def assert_in_epsilon(expected, actual, epsilon = 0.001, failure_message = nil)
      assert_in_delta(expected, actual, [expected.abs, actual.abs].min * epsilon, failure_message)
    end

    # Missing assertions (+ refutes)
    # :assert_operator, :assert_output :assert_raises, :assert_send, :assert_silent,
    # :assert_throws, :assert_mock
  end
end
