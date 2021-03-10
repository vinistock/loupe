# typed: true
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
      classes_per_group = (Ant::TestCase.classes.length.to_f / Etc.nprocessors).ceil

      ractors = Ant::TestCase.classes.each_slice(classes_per_group).map do |class_group|
        Ractor.new(class_group) do |tests|
          tests.map(&:run)
        end
      end

      ractors.flat_map(&:take).reduce(:+).print_summary # rubocop:disable Performance/Sum
    end

    private

    def require_tests(files)
      if files.empty?
        Dir["#{Dir.pwd}/test/**/*_test.rb"].each { |f| require f }
      else
        files.each { |f| require File.expand_path(f) }
      end
    end
  end
end
