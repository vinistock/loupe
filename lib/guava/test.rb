# frozen_string_literal: true

module Guava
  # Test
  #
  # The parent class for tests. Tests should
  # inherit from this class in order to be run.
  class Test # rubocop:disable Metrics/ClassLength
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

    def self.run(line_numbers = [], options = {})
      reporter = Reporter.new($stdout, options)
      test_methods = instance_methods(false).grep(/^test_.*/)

      unless line_numbers.empty?
        test_methods.select! do |method_name|
          line_numbers.include?(instance_method(method_name).source_location&.last.to_s)
        end
      end

      test_methods.shuffle!
      test_methods.each do |method_name|
        new(reporter, method_name, options).run
      rescue AssertionFailed
        next
      end

      reporter
    end

    def initialize(reporter, method_name, options = {})
      @reporter = reporter
      @color = Color.new(options[:color])
      @name = @color.p(method_name, :yellow)
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

      failure_message ||= <<~MESSAGE
        Expected #{@color.p(actual, :red)} to be #{@color.p('truthy', :green)}.
      MESSAGE

      @reporter.increment_failure_count(
        @file,
        @name,
        @line_number,
        failure_message
      )

      raise AssertionFailed
    end

    def refute(actual, failure_message = nil)
      @reporter.increment_assertion_count
      return unless actual

      failure_message ||= <<~MESSAGE
        Expected #{@color.p(actual, :red)} not to be #{@color.p('truthy', :green)}.
      MESSAGE

      @reporter.increment_failure_count(
        @file,
        @name,
        @line_number,
        failure_message
      )

      raise AssertionFailed
    end

    def assert_equal(expected, actual, failure_message = nil)
      failure_message ||= <<~MESSAGE
        Expected #{@color.p(actual, :red)} to be equal to #{@color.p(expected, :green)}."
      MESSAGE

      assert(expected == actual, failure_message)
    end

    def refute_equal(expected, actual, failure_message = nil)
      failure_message ||= <<~MESSAGE
        Expected #{@color.p(actual, :red)} to not be equal to #{@color.p(expected, :green)}."
      MESSAGE

      refute(expected == actual, failure_message)
    end

    def assert_empty(actual, failure_message = nil)
      failure_message ||= "Expected #{@color.p(actual, :red)} to be empty."
      assert(actual.empty?, failure_message)
    end

    def refute_empty(actual, failure_message = nil)
      failure_message ||= "Expected #{@color.p(actual, :red)} to not be empty."
      refute(actual.empty?, failure_message)
    end

    def assert_respond_to(object, method, failure_message = nil)
      failure_message ||= <<~MESSAGE
        Expected #{@color.p(object, :green)} to respond to #{@color.p(method, :green)}.
      MESSAGE

      assert(object.respond_to?(method.to_sym), failure_message)
    end

    def refute_respond_to(object, method, failure_message = nil)
      failure_message ||= "Expected #{@color.p(object, :green)} not to respond to #{@color.p(method, :green)}."
      refute(object.respond_to?(method.to_sym), failure_message)
    end

    def assert_includes(collection, object, failure_message = nil)
      failure_message ||= "Expected #{@color.p(collection, :green)} to include #{@color.p(object, :green)}."
      assert(collection.include?(object), failure_message)
    end

    def refute_includes(collection, object, failure_message = nil)
      failure_message ||= "Expected #{@color.p(collection, :green)} to not include #{@color.p(object, :green)}."
      refute(collection.include?(object), failure_message)
    end

    def assert_nil(actual, failure_message = nil)
      failure_message ||= "Expected #{@color.p(actual, :red)} to be nil."
      assert(actual.nil?, failure_message)
    end

    def refute_nil(actual, failure_message = nil)
      failure_message ||= "Expected #{@color.p(actual, :red)} to not be nil."
      refute(actual.nil?, failure_message)
    end

    def assert_instance_of(klass, object, failure_message = nil)
      failure_message ||= "Expected #{@color.p(object, :green)} to be an instance of #{@color.p(klass, :green)}, " \
        "not #{@color.p(object.class, :red)}."

      assert(object.instance_of?(klass), failure_message)
    end

    def refute_instance_of(klass, object, failure_message = nil)
      failure_message ||= "Expected #{@color.p(object, :green)} to not be an instance of #{@color.p(klass, :red)}."

      refute(object.instance_of?(klass), failure_message)
    end

    def assert_kind_of(klass, object, failure_message = nil)
      failure_message ||= "Expected #{@color.p(object, :green)} to be a kind of #{@color.p(klass, :red)}, " \
        "not #{@color.p(object.class, :green)}."

      assert(object.is_a?(klass), failure_message)
    end

    def refute_kind_of(klass, object, failure_message = nil)
      failure_message ||= "Expected #{@color.p(object, :green)} to not be a kind of #{@color.p(klass, :red)}."

      refute(object.is_a?(klass), failure_message)
    end

    def assert_predicate(object, method, failure_message = nil)
      failure_message ||= "Expected #{@color.p(object, :green)} to be #{@color.p(method, :red)}."

      assert(object.public_send(method), failure_message)
    end

    def refute_predicate(object, method, failure_message = nil)
      failure_message ||= "Expected #{@color.p(object, :green)} to not be #{@color.p(method, :red)}."

      refute(object.public_send(method), failure_message)
    end

    def assert_match(matcher, object, failure_message = nil)
      failure_message ||= "Expected #{@color.p(matcher, :red)} to match #{@color.p(object, :green)}."
      assert_respond_to(matcher, :=~)

      matcher = Regexp.new(Regexp.escape(matcher)) if matcher.is_a?(String)
      assert(matcher =~ object, failure_message)
    end

    def refute_match(matcher, object, failure_message = nil)
      failure_message ||= "Expected #{@color.p(matcher, :red)} to not match #{@color.p(object, :green)}."
      assert_respond_to(matcher, :=~)

      matcher = Regexp.new(Regexp.escape(matcher)) if matcher.is_a?(String)
      refute(matcher =~ object, failure_message)
    end

    def assert_same(expected, actual, failure_message = nil)
      failure_message ||= "Expected #{@color.p(expected, :green)} (#{@color.p(expected.object_id, :green)}) " \
        "to be the same as #{@color.p(actual, :red)} (#{@color.p(actual.object_id, :red)})."

      assert(expected.equal?(actual), failure_message)
    end

    def refute_same(expected, actual, failure_message = nil)
      failure_message ||= "Expected #{@color.p(expected, :green)} (#{@color.p(expected.object_id, :green)}) to not be" \
        " the same as #{@color.p(actual, :red)} (#{@color.p(actual.object_id, :red)})."

      refute(expected.equal?(actual), failure_message)
    end

    def assert_path_exists(path, failure_message = nil)
      failure_message ||= "Expected path '#{@color.p(path, :red)}' to exist."

      assert(File.exist?(path), failure_message)
    end

    def refute_path_exists(path, failure_message = nil)
      failure_message ||= "Expected path '#{@color.p(path, :red)}' to not exist."

      refute(File.exist?(path), failure_message)
    end

    def assert_in_delta(expected, actual, delta = 0.001, failure_message = nil)
      difference = (expected - actual).abs
      failure_message ||= "Expected |#{expected} - #{actual}| " \
        "(#{@color.p(difference, :red)}) to be <= #{@color.p(delta, :green)}."

      assert(delta >= difference, failure_message)
    end

    def refute_in_delta(expected, actual, delta = 0.001, failure_message = nil)
      difference = (expected - actual).abs
      failure_message ||= "Expected |#{expected} - #{actual}| " \
        "(#{@color.p(difference, :red)}) to not be <= #{@color.p(delta, :green)}."

      refute(delta >= difference, failure_message)
    end

    def assert_in_epsilon(expected, actual, epsilon = 0.001, failure_message = nil)
      assert_in_delta(expected, actual, [expected.abs, actual.abs].min * epsilon, failure_message)
    end

    def refute_in_epsilon(expected, actual, epsilon = 0.001, failure_message = nil)
      refute_in_delta(expected, actual, [expected.abs, actual.abs].min * epsilon, failure_message)
    end

    def assert_output(stdout = nil, stderr = nil, &block)
      raise ArgumentError, "assert_output requires a block to capture output." unless block

      out, err = capture_io(&block)

      match_or_equal(stdout, out) if stdout
      match_or_equal(stderr, err) if stderr
    end

    def refute_output(stdout = nil, stderr = nil, &block)
      raise ArgumentError, "assert_output requires a block to capture output." unless block

      out, err = capture_io(&block)

      refute_match_or_equal(stdout, out) if stdout
      refute_match_or_equal(stderr, err) if stderr
    end

    def assert_silent(&block)
      assert_output("", "", &block)
    end

    def refute_silent(&block)
      refute_output("", "", &block)
    end

    private

    def match_or_equal(matcher, output)
      matcher.is_a?(Regexp) ? assert_match(matcher, output) : assert_equal(matcher, output)
    end

    def refute_match_or_equal(matcher, output)
      matcher.is_a?(Regexp) ? refute_match(matcher, output) : refute_equal(matcher, output)
    end

    def capture_io
      new_stdout = StringIO.new
      new_stderr = StringIO.new
      stdout = $stdout
      stderr = $stderr
      $stdout = new_stdout
      $stderr = new_stderr

      yield

      [new_stdout.string, new_stderr.string]
    ensure
      $stdout = stdout
      $stderr = stderr
    end

    def assert_operator(first_object, operator, second_object, failure_message = nil)
      return assert_predicate(first_object, operator, failure_message) unless second_object

      failure_message ||= "Expected #{@color.p(first_object, :red)} to be #{operator}" \
        " #{@color.p(second_object, :red)}."

      assert(first_object.public_send(operator, second_object), failure_message)
    end

    def refute_operator(first_object, operator, second_object, failure_message = nil)
      return refute_predicate(first_object, operator, failure_message) unless second_object

      failure_message ||= "Expected #{@color.p(first_object, :red)} to not be #{operator}" \
        " #{@color.p(second_object, :red)}."

      refute(first_object.public_send(operator, second_object), failure_message)
    end

    # Missing assertions (+ refutes)
    # :assert_raises, :assert_send
    # :assert_throws, :assert_mock
  end
end
