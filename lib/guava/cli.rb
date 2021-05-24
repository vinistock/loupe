# frozen_string_literal: true

require "etc"
require "optparse"

module Guava
  # Cli
  #
  # The Cli class defines all available
  # commands and their options
  class Cli
    # @return [String]
    USAGE = <<~TEXT
      Usage: [test_list] [options]
    TEXT

    # @return [void]
    def initialize
      @options = {
        color: true
      }

      OptionParser.new do |opts|
        opts.banner = USAGE

        opts.on("--version", "Print Guava's version") do
          warn Guava::VERSION
          exit(0)
        end

        opts.on("--color", "--[no-]color", "Enable or disable color in the output") do |value|
          @options[:color] = value
        end
      end.parse!
      @options.freeze

      @files = ARGV
      start
    end

    private

    # @return [void]
    def start
      require_tests

      ractors = Guava::Test.classes.each_slice(classes_per_group).flat_map do |class_group|
        Ractor.new(class_group, @options) do |tests, options|
          tests.map { |test, line_numbers| test.run(line_numbers, options) }
        end
      end

      reporter = ractors.flat_map(&:take).reduce(:+) # rubocop:disable Performance/Sum
      reporter.print_summary
      exit(reporter.exit_status)
    end

    # @return [Integer]
    def classes_per_group
      (Guava::Test.classes.length.to_f / Etc.nprocessors).ceil
    end

    # @return [void]
    def require_tests
      require "#{Dir.pwd}/test/test_helper"

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
