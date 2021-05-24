# frozen_string_literal: true

module Guava
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

    # @return [Array<Guava::Failure>]
    attr_reader :failures

    # @param io [IO]
    # @param options [Hash<Symbol, BasicObject>]
    # @return [Guava::Reporter]
    def initialize(io = $stdout, options = {})
      @io = io
      @color = Color.new(options[:color])
      @test_count = 0
      @expectation_count = 0
      @success_count = 0
      @failure_count = 0
      @failures = []
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
      @io.print(@color.p(".", :green))
      @success_count += 1
    end

    # @return [void]
    def increment_failure_count(file_name, test_name, line_number, message)
      @io.print(@color.p("F", :red))
      @failures << Failure.new(file_name, test_name, message, line_number)
      @failure_count += 1
    end

    # @param other [Guava::Reporter]
    # @return [Guava::Reporter]
    def +(other)
      @test_count += other.test_count
      @expectation_count += other.expectation_count
      @success_count += other.success_count
      @failure_count += other.failure_count
      @failures.concat(other.failures)
      self
    end

    # @return [void]
    def print_summary
      if @failures.empty?
        report = ""
      else
        report = +"\n\n"
        report << @failures.map!(&:to_s).join("\n")
      end

      @io.print "\n\n"
      @io.print <<~SUMMARY
        Tests: #{@test_count} Expectations: #{@expectation_count}
        Passed: #{@success_count} Failures: #{@failure_count}#{report}
      SUMMARY
    end

    # @return [Integer]
    def exit_status
      @failure_count.zero? ? 0 : 1
    end
  end
end
