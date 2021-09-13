# frozen_string_literal: true

# Loupe's expectations and execution flow are heavily inspired by or adapted from Minitest and rspec-expectations
# implementations. The originals licenses can be found below.
#
# Minitest
# https://github.com/seattlerb/minitest
#
# (The MIT License)
#
# Copyright © Ryan Davis, seattle.rb
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
# OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#   Rspec-expectations
#
# https://github.com/rspec/rspec-expectations
#
# The MIT License (MIT)
#
#     Copyright © 2012 David Chelimsky, Myron Marston Copyright © 2006 David Chelimsky, The RSpec Development Team
#     Copyright © 2005 Steven Baker
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
# OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Loupe
  # Expectation
  #
  # This class is responsible for instantiating a target
  # so that expectations can be invoked on it.
  #
  # Example:
  #   expectation = Expectation.new(target, test)
  #   expectation.to_be_empty
  #
  # The goal of ths class is so that expectations can be written
  # in such a way that they read in plain English.
  # E.g.: expect(something).to_be_truthy
  #
  # @see Loupe::Test#expect
  class Expectation # rubocop:disable Metrics/ClassLength
    class ExpectationFailed < StandardError; end

    # @param target [BasicObject]
    # @param test [Loupe::Test]
    # @return [Loupe::Expectation]
    def initialize(target, test)
      @target = target
      @color = test.color
      @test = test
    end

    # expect(target).to_be_truthy
    #
    # Expects `target` to be a truthy value (not `nil` or `false`).
    #
    # @return [Loupe::Expectation]
    def to_be_truthy
      assert(@target, "Expected #{@color.p(@target.inspect, :red)} to be #{@color.p('truthy', :green)}.")
    end

    # expect(target).to_be_falsey
    #
    # Expects `target` to be a falsey value (`nil` or `false`).
    #
    # @return [Loupe::Expectation]
    def to_be_falsey
      assert(!@target, "Expected #{@color.p(@target.inspect, :red)} to be #{@color.p('falsey', :green)}.")
    end

    # expect(target).to_be_equal_to(value)
    #
    # Expects `target` to be equal to `value`. Compares if the objects are equal in terms of values
    # but not if the objects are the exact same instance. For comparing identity, use {#to_be_the_same_as}.
    #
    # @param value [#==]
    # @return [Loupe::Expectation]
    def to_be_equal_to(value)
      assert(
        @target == value,
        "Expected #{@color.p(@target.inspect, :red)} to be equal to #{@color.p(value.inspect, :green)}."
      )
    end

    # expect(target).to_not_be_equal_to(value)
    #
    # Expects `target` to not be equal to `value`. Compares if the objects are different in terms of values,
    # but not if the objects are the different instances. For comparing identity, use {#to_not_be_the_same_as}.
    #
    # @param value [#!=]
    # @return [Loupe::Expectation]
    def to_not_be_equal_to(value)
      assert(
        @target != value,
        "Expected #{@color.p(@target.inspect, :red)} to not be equal to #{@color.p(value.inspect, :green)}."
      )
    end

    # expect(target).to_be_empty
    #
    # Expects `target` to be empty. Which means invoking `empty?` must return `true`.
    #
    # @return [Loupe::Expectation]
    def to_be_empty
      assert(@target.empty?, "Expected #{@color.p(@target.inspect, :red)} to be empty.")
    end

    # expect(target).to_not_be_empty
    #
    # Expects `target` to not be empty. Which means invoking `empty?` must return `false`.
    #
    # @return [Loupe::Expectation]
    def to_not_be_empty
      assert(!@target.empty?, "Expected #{@color.p(@target.inspect, :red)} to not be empty.")
    end

    # expect(target).to_respond_to(method)
    #
    # Expects `target` to respond to `method`. This expectation passes if `method` exists in `target`.
    #
    # @param method [String, Symbol]
    # @return [Loupe::Expectation]
    def to_respond_to(method)
      assert(
        @target.respond_to?(method.to_sym),
        "Expected #{@color.p(@target.inspect, :red)} to respond to #{@color.p(method, :green)}."
      )
    end

    # expect(target).to_not_respond_to(method)
    #
    # Expects `target` to not respond to `method`. This expectation passes if `method` does not exist in `target`.
    #
    # @param method [String, Symbol]
    # @return [Loupe::Expectation]
    def to_not_respond_to(method)
      assert(
        !@target.respond_to?(method.to_sym),
        "Expected #{@color.p(@target.inspect, :red)} to not respond to #{@color.p(method, :green)}."
      )
    end

    # expect(target).to_include(object)
    #
    # Expects `target` to include `object`. In this expectation, `target` is typically a collection
    # or another object that responds to `include?`. The expectation passes if `target` includes `object`.
    #
    # @param object [BasicObject]
    # @return [Loupe::Expectation]
    def to_include(object)
      assert(
        @target.include?(object),
        "Expected #{@color.p(@target.inspect, :red)} to include #{@color.p(object, :green)}."
      )
    end

    # expect(target).to_not_include(object)
    #
    # Expects `target` to not include `object`. In this expectation, `target` is typically a collection
    # or another object that responds to `include?`. The expectation passes if `target` does not include `object`.
    #
    # @param object [BasicObject]
    # @return [Loupe::Expectation]
    def to_not_include(object)
      assert(
        !@target.include?(object),
        "Expected #{@color.p(@target.inspect, :red)} to not include #{@color.p(object, :green)}."
      )
    end

    # expect(target).to_be_nil
    #
    # Expects `target` to be `nil`.
    #
    # @return [Loupe::Expectation]
    def to_be_nil
      assert(@target.nil?, "Expected #{@color.p(@target.inspect, :red)} to be nil.")
    end

    # expect(target).to_not_be_nil
    #
    # Expects `target` not to be `nil`.
    #
    # @return [Loupe::Expectation]
    def to_not_be_nil
      assert(!@target.nil?, "Expected #{@color.p(@target.inspect, :red)} to not be nil.")
    end

    # expect(target).to_be_an_instance_of(klass)
    #
    # Expects `target` to be an instance of `klass`. For example, "ruby is awesome" is
    # an instance of `String` and will pass the expectation.
    #
    # @param klass [Class]
    # @return [Loupe::Expectation]
    def to_be_an_instance_of(klass)
      failure_message = "Expected #{@color.p(@target.inspect, :red)} to be an instance " \
                        "of #{@color.p(klass, :green)}, not #{@color.p(@target.inspect.class, :red)}."

      assert(@target.instance_of?(klass), failure_message)
    end

    # expect(target).to_not_be_an_instance_of(klass)
    #
    # Expects `target` to not be an instance of `klass`. For example, "ruby is awesome" is
    # not an instance of `Integer` and will not pass the expectation.
    #
    # @param klass [Class]
    # @return [Loupe::Expectation]
    def to_not_be_an_instance_of(klass)
      failure_message = "Expected #{@color.p(@target.inspect, :red)} to not be an instance of " \
                        "#{@color.p(klass, :green)}, not #{@color.p(@target.inspect.class, :red)}."

      assert(!@target.instance_of?(klass), failure_message)
    end

    # expect(target).to_be_a_kind_of(klass)
    #
    # Expects `target` to be a kind of `klass`. Which means that if `target.is_a?(klass)` returns true,
    # the expectation will pass.
    #
    # @param klass [Class]
    # @return [Loupe::Expectation]
    def to_be_a_kind_of(klass)
      failure_message = "Expected #{@color.p(@target.inspect, :red)} to be a kind of " \
                        "#{@color.p(klass, :green)}, not #{@color.p(@target.inspect.class, :red)}."

      assert(@target.is_a?(klass), failure_message)
    end

    # expect(target).to_not_be_a_kind_of(klass)
    #
    # Expects `target` to not be a kind of `klass`. Which means that if `target.is_a?(klass)` returns false,
    # the expectation will pass.
    #
    # @param klass [Class]
    # @return [Loupe::Expectation]
    def to_not_be_a_kind_of(klass)
      failure_message = "Expected #{@color.p(@target.inspect, :red)} to not be a kind of " \
                        "#{@color.p(klass, :green)}, not #{@color.p(@target.inspect.class, :red)}."

      assert(!@target.is_a?(klass), failure_message)
    end

    # expect(target).to_be(predicate)
    #
    # Expects `target` to return `true` for a given `predicate`. In this expectation, `predicate` is a method name and
    # the expectation will pass if invoking the method on `target` returns `true`.
    #
    # Example:
    #   Verify if the result of a calculation is an odd number. The `target` is the calculation result
    #   and the `predicate` is the method `odd?`.
    #
    #   calculation_result = a_complex_math_operation
    #   expect(calculation_result).to_be(:odd?)
    #
    # @param predicate [String, Symbol]
    # @return [Loupe::Expectation]
    def to_be(predicate)
      assert(
        @target.public_send(predicate),
        "Expected #{@color.p(@target.inspect, :red)} to be #{@color.p(predicate, :green)}."
      )
    end

    # expect(target).to_not_be(predicate)
    #
    # Expects `target` to return `false` for a given `predicate`. In this expectation, `predicate` is a method name and
    # the expectation will pass if invoking the method on `target` returns `false`.
    #
    # Example:
    #   Verify if the result of a calculation is not zero. The `target` is the calculation result
    #   and the `predicate` is the method `zero?`.
    #
    #   calculation_result = a_complex_math_operation
    #   expect(calculation_result).to_not_be(:zero?)
    #
    # @param predicate [String, Symbol]
    # @return [Loupe::Expectation]
    def to_not_be(predicate)
      assert(
        !@target.public_send(predicate),
        "Expected #{@color.p(@target.inspect, :red)} to not be #{@color.p(predicate, :green)}."
      )
    end

    # expect(target).to_match(object)
    #
    # Expects `target` to match `object`. In this expectation, `target` is a matcher (string or a regex)
    # that must match `object`. The matcher needs to respond to `=~` and needs to return `true` when it is
    # invoked with `object`.
    #
    # Example:
    #   expect(/ruby .*/).to_match("ruby is awesome")
    #   expect("awesome").to_match("ruby is awesome")
    #
    # @param object [BasicObject]
    # @return [Loupe::Expectation]
    def to_match(object)
      to_respond_to(:=~)

      @target = Regexp.new(Regexp.escape(@target)) if @target.is_a?(String)
      assert(@target =~ object, "Expected #{@color.p(@target.inspect, :red)} to match #{@color.p(object, :green)}.")
    end

    # expect(target).to_not_match(object)
    #
    # Expects `target` to not match `object`. In this expectation, `target` is a matcher (string or a regex)
    # that must not match `object`. The matcher needs to respond to `=~` and needs to return `false` when it is
    # invoked with `object`.
    #
    # Example:
    #   expect(/python .*/).to_not_match("ruby is awesome")
    #   expect("terrible").to_not_match("ruby is awesome")
    #
    # @param object [BasicObject]
    # @return [Loupe::Expectation]
    def to_not_match(object)
      to_respond_to(:=~)

      @target = Regexp.new(Regexp.escape(@target)) if @target.is_a?(String)
      assert(@target !~ object, "Expected #{@color.p(@target.inspect, :red)} to not match #{@color.p(object, :green)}.")
    end

    # expect(target).to_be_the_same_as(object)
    #
    # Expects `target` to be the same as `object`. This means, `target` and `object` must be the exact same
    # object, with the same `object_id`.
    #
    # @param object [BasicObject]
    # @return [Loupe::Expectation]
    def to_be_the_same_as(object)
      failure_message = "Expected #{@color.p(@target.inspect, :red)} (#{@color.p(@target.inspect.object_id, :red)}) " \
                        "to be the same as #{@color.p(object, :green)} (#{@color.p(object.object_id, :green)})."

      assert(@target.equal?(object), failure_message)
    end

    # expect(target).to_not_be_the_same_as(object)
    #
    # Expects `target` to not be the same as `object`. This means, `target` and `object` are not the exact
    # same object with the same `object_id`.
    #
    # Note: this is an identity comparison. If the values of both objects are the same, but the object IDs are
    # different, this expectation will pass.
    #
    # @param object [BasicObject]
    # @return [Loupe::Expectation]
    def to_not_be_the_same_as(object)
      failure_message = "Expected #{@color.p(@target.inspect, :red)} (#{@color.p(@target.inspect.object_id, :red)}) " \
                        "to not be the same as #{@color.p(object, :green)} (#{@color.p(object.object_id, :green)})."

      assert(!@target.equal?(object), failure_message)
    end

    # expect(target).to_be_an_existing_path
    #
    # Expects `target` to be an existing path in the file system. That means, invoking `File.exist?(target)`
    # must return `true` for this expectation to pass.
    #
    # @return [Loupe::Expectation]
    def to_be_an_existing_path
      assert(File.exist?(@target), "Expected path '#{@color.p(@target.inspect, :red)}' to exist.")
    end

    # expect(target).to_not_be_an_existing_path
    #
    # Expects `target` to not be an existing path in the file system. That means, invoking `File.exist?(target)`
    # must return `false` for this expectation to pass.
    #
    # @return [Loupe::Expectation]
    def to_not_be_an_existing_path
      assert(!File.exist?(@target), "Expected path '#{@color.p(@target.inspect, :red)}' to not exist.")
    end

    # expect(target).to_be_in_delta_of(value, delta = 0.001)
    #
    # Expects `target` to be within `delta` of `value`. This means that the absolute difference between
    # `target` and `value` cannot be bigger than `delta`.
    #
    # Example:
    #   expect(5.0).to_be_in_delta_of(5.1, 0.2)
    #
    # @param value [Numeric]
    # @param delta [Numeric]
    # @return [Loupe::Expectation]
    def to_be_in_delta_of(value, delta = 0.001)
      difference = (@target - value).abs

      failure_message = "Expected |#{@target} - #{value}| " \
                        "(#{@color.p(difference, :red)}) to be <= #{@color.p(delta, :green)}."

      assert(delta >= difference, failure_message)
    end

    # expect(target).to_not_be_in_delta_of(value, delta = 0.001)
    #
    # Expects `target` to not be within `delta` of `value`. This means that the absolute difference between
    # `target` and `value` must be bigger than `delta`.
    #
    # Example:
    #   expect(5.0).to_not_be_in_delta_of(5.1, 0.01)
    #
    # @param value [Numeric]
    # @param delta [Numeric]
    # @return [Loupe::Expectation]
    def to_not_be_in_delta_of(value, delta = 0.001)
      difference = (@target - value).abs

      failure_message = "Expected |#{@target} - #{value}| " \
                        "(#{@color.p(difference, :red)}) to not be <= #{@color.p(delta, :green)}."

      assert(delta <= difference, failure_message)
    end

    # expect(target).to_be_in_epsilon_of(value, epsilon = 0.001)
    #
    # Expects `target` to be within `epsilon` times the smallest absolute value between `value` and `target`.
    # This expectation simply invokes {#to_be_in_delta_of},
    # where the `delta` is `epsilon * [@target.abs, value.abs].min`.
    #
    # Example:
    #   The minimum absolute value between 5.0 and 5.1 is equal to 5.0.
    #   The delta is equal to 5.0 * 0.1, which is 0.5.
    #   The absolute difference 5.1 - 5.0 is 0.1.
    #   0.1 is smaller than 0.5, therefore the expectation passes.
    #
    #   expect(5.0).to_be_in_epsilon_of(5.1, 0.1)
    #
    # @param value [Numeric]
    # @param epsilon [Numeric]
    # @return [Loupe::Expectation]
    def to_be_in_epsilon_of(value, epsilon = 0.001)
      to_be_in_delta_of(value, [@target.abs, value.abs].min * epsilon)
    end

    # expect(target).to_not_be_in_epsilon_of(value, epsilon = 0.001)
    #
    # Expects `target` to not be within `epsilon` times the smallest absolute value between `value` and `target`.
    # This expectation simply invokes {#to_not_be_in_delta_of},
    # where the `delta` is `epsilon * [@target.abs, value.abs].min`.
    #
    # Example:
    #   The minimum absolute value between 5.0 and 5.1 is equal to 5.0.
    #   The delta is equal to 5.0 * 0.01, which is 0.05.
    #   The absolute difference 5.1 - 5.0 is 0.1.
    #   0.1 is not smaller than 0.05, therefore the expectation passes.
    #
    #   expect(5.0).to_not_be_in_epsilon_of(5.1, 0.01)
    #
    # @param value [Numeric]
    # @param epsilon [Numeric]
    # @return [Loupe::Expectation]
    def to_not_be_in_epsilon_of(value, epsilon = 0.001)
      to_not_be_in_delta_of(value, [@target.abs, value.abs].min * epsilon)
    end

    # expect(target).to_satisfy_operator(operator, other)
    #
    # Expects `target` to return true when the `operator` is applied on `other`.
    # This expectation is used to verify operations between two objects.
    #
    # Example:
    #
    #   expect(5.0).to_satisfy_operator(:>, 4.9)
    #
    # @param operator [Symbol]
    # @param other [BasicObject]
    # @return [Loupe::Expectation]
    def to_satisfy_operator(operator, other)
      return to_be(operator) unless other

      failure_message = "Expected #{@color.p(@target.inspect, :red)} to be #{operator}" \
                        " #{@color.p(other, :green)}."

      assert(@target.public_send(operator, other), failure_message)
    end

    # expect(target).to_not_satisfy_operator(operator, other)
    #
    # Expects `target` to return false when the `operator` is applied on `other`.
    # This expectation is used to verify operations between two objects.
    #
    # Example:
    #
    #   expect(5.0).to_not_satisfy_operator(:<, 4.9)
    #
    # @param operator [Symbol]
    # @param other [BasicObject]
    # @return [Loupe::Expectation]
    def to_not_satisfy_operator(operator, other)
      return to_not_be(operator) unless other

      failure_message = "Expected #{@color.p(@target.inspect, :red)} to not be #{operator}" \
                        " #{@color.p(other, :green)}."

      assert(!@target.public_send(operator, other), failure_message)
    end

    private

    # Base assertion for all expectations. This is where result are passed to the reported
    # and where the test execution is halted if any expectation fails.
    #
    # @param value [BasicObject]
    # @param failure_message [String]
    # @return [Loupe::Expectation]
    def assert(value, failure_message)
      @test.reporter.increment_expectation_count
      return self if value

      @test.reporter.increment_failure_count(@test, failure_message)
      raise ExpectationFailed
    end
  end
end
