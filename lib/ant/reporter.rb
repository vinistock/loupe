# typed: true
# frozen_string_literal: true

module Ant
  # Reporter
  #
  # Class that handles reporting test results
  # and progress.
  class Reporter
    attr_reader :test_count, :assertion_count, :success_count, :failure_count,
                :failure_report

    def initialize(io = $stdout)
      @io = io
      @test_count = 0
      @assertion_count = 0
      @success_count = 0
      @failure_count = 0
      @failure_report = Hash.new { |a, b| a[b] = Hash.new({}) }
    end

    def increment_test_count
      @test_count += 1
    end

    def increment_assertion_count
      @assertion_count += 1
    end

    def increment_success_count
      @io.print("\033[1;32m.\033[0m")
      @success_count += 1
    end

    def increment_failure_count(file_name, test_name, line_number, message)
      @io.print("\033[1;31mF\033[0m")
      @failure_report[file_name][test_name] = { message: message, line_number: line_number }
      @failure_count += 1
    end

    def +(other)
      @test_count += other.test_count
      @assertion_count += other.assertion_count
      @success_count += other.success_count
      @failure_count += other.failure_count
      @failure_report.merge!(other.failure_report)
      self
    end

    def print_summary
      if @failure_report.empty?
        report = ""
      else
        report = +"\n\n"
        report << @failure_report.flat_map do |file, result|
          result.map do |method, info|
            "#{file}:#{info[:line_number]} at #{method}. #{info[:message]}"
          end.join("\n")
        end.join("\n")
      end

      @io.print "\n\n"
      @io.print <<~SUMMARY
        Tests: #{@test_count} Assertions: #{@assertion_count}
        Passed: #{@success_count} Failures: #{@failure_count}#{report}
      SUMMARY
    end

    def exit_status
      @failure_count.zero? ? 0 : 1
    end
  end
end
