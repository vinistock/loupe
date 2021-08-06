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
    def initialize
      @options = {
        color: true,
        interactive: true
      }

      parse_options(@options)
      @options.freeze

      @files = ARGV
      start
    end

    private

    # @param options [Hash<Symbol, BasicObject>]
    # @return [void]
    def parse_options(options)
      OptionParser.new do |opts|
        opts.banner = USAGE

        opts.on("--version", "Print Loupe's version") do
          warn Loupe::VERSION
          exit(0)
        end

        opts.on("--color", "--[no-]color", "Enable or disable color in the output") { |value| options[:color] = value }
        opts.on("--interactive", "Use interactive output") { options[:interactive] = true }
        opts.on("--plain", "Use plain non-interactive output") { options[:interactive] = false }

        opts.on("--editor=EDITOR", "The editor to open test files with in interactive mode") do |value|
          options[:editor] = value
        end
      end.parse!
    end

    # @return [void]
    def start
      require_tests
      exit(Executor.new(@options).run)
    end

    # @return [void]
    def require_tests
      require "#{Dir.pwd}/test/test_helper"

      if @files.empty?
        Dir["#{Dir.pwd}/test/**/*_test.rb"].each { |f| require f }
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
