# frozen_string_literal: true

require "optparse"

module Loupe
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
    def initialize # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      @options = {
        color: true,
        interactive: true
      }

      OptionParser.new do |opts|
        opts.banner = USAGE

        opts.on("--version", "Print Loupe's version") do
          warn Loupe::VERSION
          exit(0)
        end

        opts.on("--color", "--[no-]color", "Enable or disable color in the output") do |value|
          @options[:color] = value
        end

        opts.on("--interactive", "Use interactive output") do
          @options[:interactive] = true
        end

        opts.on("--plain", "Use plain non-interactive output") do
          @options[:interactive] = false
        end

        opts.on("--editor=EDITOR", "Select the editor to open test files with in interactive mode") do |value|
          raise ArgumentError, "--editor can only be select in interative mode" unless @options[:interactive]

          @options[:editor] = value
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
      exit(Executor.new(@options).run)
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
          Test.add_line_number(line_number) if line_number
        end
      end
    end
  end
end
