# frozen_string_literal: true

module Loupe
  # PlainReporter
  #
  # A simple reporter that just prints dots and Fs to
  # the terminal
  class PlainReporter < Reporter
    # @return [void]
    def print_summary
      if @failures.empty?
        report = ""
      else
        report = +"\n\n"
        report << @failures.map!(&:to_s).join("\n")
      end

      print "\n\n"
      print <<~SUMMARY
        Tests: #{@test_count} Expectations: #{@expectation_count}
        Passed: #{@success_count} Failures: #{@failure_count}#{report}

        Finished in #{Time.now - @start_time} seconds
      SUMMARY
    end
  end
end
