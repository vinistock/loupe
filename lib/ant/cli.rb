# typed: false
# frozen_string_literal: true

require "thor"
require "etc"

module Ant
  # Cli
  #
  # The Cli class defines all available
  # commands and their options
  class Cli < Thor
    desc "test [paths]", "run tests"
    def test(*files)
      require_tests(files)

      ractors = Ant::TestCase.classes.each_slice(classes_per_group).map do |class_group|
        Ractor.new(class_group) do |tests|
          tests.map { |test, line_numbers| test.run(line_numbers) }
        end
      end

      ractors.flat_map(&:take).reduce(:+).print_summary # rubocop:disable Performance/Sum
    end

    private

    def classes_per_group
      (Ant::TestCase.classes.length.to_f / Etc.nprocessors).ceil
    end

    def require_tests(files)
      if files.empty?
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
