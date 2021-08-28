# frozen_string_literal: true

require "loupe"
require "rake"
require "rake/tasklib"

module Loupe
  # Loupe's test rake task
  #
  # Define a rake task so that we can hook into `rake test`
  # an run the suite using Loupe. To hook it up, add this to the Rakefile
  #
  # require "loupe/rake_task"
  #
  # Loupe::RakeTask.new do |options|
  #   options << "--plain"
  #   options << "--ractor"
  # end
  #
  # Then run with `bundle exec rake test`
  #
  class RakeTask < Rake::TaskLib
    attr_accessor :name, :description, :libs

    # @return [Loupe::RakeTask]
    def initialize
      super

      @name = "test"
      @description = "Run tests using Loupe"
      @libs = %w[lib test]
      @options = []
      ARGV.shift if ARGV.first == "test"
      yield(@options)
      define
    end

    private

    # @return [Loupe::RakeTask]
    def define
      desc @description
      task(@name) { Loupe::Cli.new(@options) }
      self
    end
  end
end
