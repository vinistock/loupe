# frozen_string_literal: true

require "etc"
require "optparse"

module Guava
  # Cli
  #
  # The Cli class defines all available
  # commands and their options
  class Cli
    USAGE = <<~TEXT
      Usage: [test_list] [options]
    TEXT

    def initialize
      OptionParser.new do |opts|
        opts.banner = USAGE

        opts.on("--version", "Print Guava's version") do
          warn Guava::VERSION
          exit(0)
        end
      end.parse!

      @files = ARGV
      start
    end

    private

    def start
      require_tests

      ractors = Guava::Test.classes.each_slice(classes_per_group).flat_map do |class_group|
        Ractor.new(class_group) do |tests|
          tests.map { |test, line_numbers| test.run(line_numbers) }
        end
      end

      reporter = ractors.flat_map(&:take).reduce(:+) # rubocop:disable Performance/Sum
      reporter.print_summary
      exit(reporter.exit_status)
    end

    def classes_per_group
      (Guava::Test.classes.length.to_f / Etc.nprocessors).ceil
    end

    def require_tests
      if @files.nil?
        Dir["#{Dir.pwd}/test/**/*_test.rb"]
          .tap(&:shuffle!)
          .each { |f| require f }
      else
        @files.each do |f|
          file, line_number = f.split(":")
          require File.expand_path(file)
          Guava::Test.add_line_number(line_number) if line_number
        end
      end
    end
  end
end
