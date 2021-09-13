# frozen_string_literal: true

# Loupe's expectations are heavily inspired by or adapted from Minitest and rspec-expectations implementations. The
# originals licenses can be found below.
#
# Minitest https://github.com/seattlerb/minitest
#
# (The MIT License)
#
# Copyright © Ryan Davis, seattle.rb
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the 'Software'), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of
# the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

# Rspec-expectations
#
# https://github.com/rspec/rspec-expectations
#
# The MIT License (MIT)
#
# Copyright © 2012 David Chelimsky, Myron Marston Copyright © 2006 David Chelimsky, The RSpec Development Team
# Copyright © 2005 Steven Baker
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of
# the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

module Loupe
  # Test
  #
  # The parent class for tests. Tests should
  # inherit from this class in order to be run.
  class Test
    # @return [Loupe::Reporter]
    attr_reader :reporter

    # @return [Integer]
    attr_reader :line_number

    # @return [String]
    attr_reader :file

    # @return [Loupe::Color]
    attr_reader :color

    # @return [String]
    attr_reader :name

    # @return [Hash<Class, Array<Integer>>]
    def self.classes
      @classes ||= {}
    end

    # @param number [Integer]
    # @return [void]
    def self.add_line_number(number)
      classes[@current_class] << number
    end

    # @param test_class [Class]
    # @return [void]
    def self.inherited(test_class)
      @current_class = test_class
      classes[test_class] = []
      super
    end

    # @return [Array<Symbol>]
    def self.test_list
      instance_methods(false).grep(/^test.*/)
    end

    # Run a single test with designated by `method_name`
    #
    # @param method_name [Symbol]
    # @param options [Hash<Symbol, BasicObject>]
    # @return [Loupe::Reporter]
    def self.run(method_name, options = {})
      reporter = options[:interactive] ? PagedReporter.new(options) : PlainReporter.new(options)
      new(reporter, method_name, options).run
      reporter
    rescue Expectation::ExpectationFailed
      reporter
    end

    # @param reporter [Loupe::Reporter]
    # @param method_name [Symbol]
    # @param options [Hash<Symbol, BasicObject>]
    # @return [Loupe::Test]
    def initialize(reporter, method_name, options = {})
      @reporter = reporter
      @color = Color.new(options[:color])
      @name = method_name
      @method = method(method_name)
      @file, @line_number = @method.source_location
    end

    # Run the instantiated test, which corresponds to a single
    # method.
    # @return [void]
    def run
      @reporter.increment_test_count
      before
      @method.call
      after
      @reporter.increment_success_count
    end

    # @return [void]
    def before; end

    # @return [void]
    def after; end

    protected

    # expect(target)
    #
    # Initial construct for any expectation. Instantiates an Expectation object
    # on which verifications can be performed. Any expectation can be chained to reuse
    # the object if the `target` is the same.
    #
    # Example:
    #   expect(collection)
    #     .to_not_be_empty
    #     .to_include(object)
    #     .be_an_instance_of(Array)
    #
    # @return [Loupe::Expectation]
    def expect(target)
      Expectation.new(target, self)
    end

    # expect_output_to_match(stdout, stderr) { block }
    #
    # Expects the output generated by the execution of `block` to match the matchers used
    # for `stdout` and `stderr`. If the `block` only prints to one of the two, simply pass
    # `nil` for the one that is not of interest.
    #
    # Example:
    # expect_output_to_match("foo") do
    #   puts "foo"
    # end
    #
    # expect_output_to_match(nil, /error: .*/) do
    #   $stderr.puts "error: operation failed"
    # end
    #
    # @return [void]
    def expect_output_to_match(stdout = nil, stderr = nil, &block)
      raise ArgumentError, "expect_output_to_match requires a block to capture output." unless block

      out, err = capture_io(&block)

      match_or_equal(stdout, out) if stdout
      match_or_equal(stderr, err) if stderr
    end

    # expect_output_to_not_match(stdout, stderr) { block }
    #
    # Expects the output generated by the execution of `block` to not match the matchers used
    # for `stdout` and `stderr`. If the `block` only prints to one of the two, simply pass
    # `nil` for the one that is not of interest.
    #
    # Example:
    # expect_output_to_not_match("foo") do
    #   puts "bar"
    # end
    #
    # expect_output_to_not_match(nil, /error: network failed.*/) do
    #   $stderr.puts "error: record not unique"
    # end
    #
    # @return [void]
    def expect_output_to_not_match(stdout = nil, stderr = nil, &block)
      raise ArgumentError, "expect_output_to_not_match requires a block to capture output." unless block

      out, err = capture_io(&block)

      refute_match_or_equal(stdout, out) if stdout
      refute_match_or_equal(stderr, err) if stderr
    end

    # expect_output_to_be_empty { block }
    #
    # Expects the output generated by `block` to be empty for both `$stdout` and `$stderr`.
    # That is, expects the `block` to not print anything to either `$stdout` or `$stderr`.
    # For matching to the output of the `block`, see {#expect_output_to_match}.
    #
    # Example:
    # expect_output_to_be_empty do
    #   puts "bar" if false
    # end
    #
    # @return [void]
    def expect_output_to_be_empty(&block)
      expect_output_to_match("", "", &block)
    end

    # expect_output_to_not_be_empty { block }
    #
    # Expects the output generated by `block` to not be empty for both `$stdout` and `$stderr`.
    # That is, expects the `block` to print something to either `$stdout` or `$stderr`.
    # For matching to the output of the `block`, see {#expect_output_to_not_match}.
    #
    # Example:
    # expect_output_to_not_be_empty do
    #   puts "foo"
    # end
    #
    # @return [void]
    def expect_output_to_not_be_empty(&block)
      expect_output_to_not_match("", "", &block)
    end

    private

    # @param matcher [Regexp, String]
    # @param output [String]
    # @return [void]
    def match_or_equal(matcher, output)
      matcher.is_a?(Regexp) ? expect(matcher).to_match(output) : expect(matcher).to_be_equal_to(output)
    end

    # @param matcher [Regexp, String]
    # @param output [String]
    # @return [void]
    def refute_match_or_equal(matcher, output)
      matcher.is_a?(Regexp) ? expect(matcher).to_not_match(output) : expect(matcher).to_not_be_equal_to(output)
    end

    # @return [Array<String>]
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
  end
end
