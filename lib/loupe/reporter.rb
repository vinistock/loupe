# frozen_string_literal: true

# Loupe's reporter structure is heavily inspired by or adapted from Minitest. The
# originals license can be found below.
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

module Loupe
  # Reporter
  #
  # Class that handles reporting test results
  # and progress.
  class Reporter
    # @return [Integer]
    attr_reader :test_count

    # @return [Integer]
    attr_reader :expectation_count

    # @return [Integer]
    attr_reader :success_count

    # @return [Integer]
    attr_reader :failure_count

    # @return [Array<Loupe::Failure>]
    attr_reader :failures

    # @param options [Hash<Symbol, BasicObject>]
    # @return [Loupe::Reporter]
    def initialize(options = {})
      @options = options
      @color = Color.new(options[:color])
      @options = options
      @test_count = 0
      @expectation_count = 0
      @success_count = 0
      @failure_count = 0
      @failures = []
      @start_time = Time.now
    end

    # @return [void]
    def increment_test_count
      @test_count += 1
    end

    # @return [void]
    def increment_expectation_count
      @expectation_count += 1
    end

    # @return [void]
    def increment_success_count
      print(@color.p(".", :green))
      @success_count += 1
    end

    # @param test [Loupe::Test]
    # @return [void]
    def increment_failure_count(test, message)
      print(@color.p("F", :red))
      @failures << Failure.new(test, message)
      @failure_count += 1
    end

    # @param other [Loupe::Reporter]
    # @return [Loupe::Reporter]
    def <<(other)
      @test_count += other.test_count
      @expectation_count += other.expectation_count
      @success_count += other.success_count
      @failure_count += other.failure_count
      @failures.concat(other.failures)
      self
    end

    # @return [Integer]
    def exit_status
      @failure_count.zero? ? 0 : 1
    end

    # @return [void]
    def print_summary
      raise NotImplementedError, "Print must be implemented in the inheriting reporter class"
    end
  end
end
