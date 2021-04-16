# frozen_string_literal: true

require "thor"
require "etc"

module Ant
  # Cli
  #
  # The Cli class defines all available
  # commands and their options
  class Cli < Thor
    default_command "test"

    desc "test", "run tests"
    argument("files", required: false, desc: "The list of test files to run", type: :array)
    def test
      require_tests(files)

      ractors = Ant::TestCase.classes.each_slice(classes_per_group).flat_map do |class_group|
        Ractor.new(class_group) do |tests|
          tests.map { |test, line_numbers| test.run(line_numbers) }
        end
      end

      reporter = ractors.flat_map(&:take).reduce(:+) # rubocop:disable Performance/Sum
      reporter.print_summary
      exit(reporter.exit_status)
    end

    # If invoked through the default_command with a
    # list of tests, Thor will not find the command.
    # Redirect it back to the test command. E.g.:
    # bundle exec ant test/my_test.rb
    def self.handle_no_command_error(_name)
      ARGV.unshift("test")
      start(ARGV)
    end

    private

    # Number of classes per Ractor group
    def classes_per_group
      (Ant::TestCase.classes.length.to_f / Etc.nprocessors).ceil
    end

    # Require the test files. If none selected, run entire suite
    def require_tests(files)
      if files.nil?
        Dir["#{Dir.pwd}/test/**/*_test.rb"].each { |f| require f }
      else
        files.each do |f|
          file, line_number = f.split(":")
          require File.expand_path(file)
          Ant::TestCase.add_line_number(line_number) if line_number
        end
      end
    end
  end
end
