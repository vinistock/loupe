# frozen_string_literal: true

module Guava
  # Failure
  #
  # This class represents a single test failure. It corresponds
  # to one method that was executed and had failed expectations.
  class Failure
    # @return [String]
    attr_reader :file_name

    # @return [String]
    attr_reader :test_name

    # @return [String]
    attr_reader :message

    # @return [Integer]
    attr_reader :line_number

    # @return [Class]
    attr_reader :klass

    # @param test [Guava::Test]
    # @param message [String]
    # @return [Guava::Failure]
    def initialize(test, message)
      @file_name = test.file
      @test_name = test.name
      @line_number = test.line_number
      @klass = test.class
      @color = test.color
      @message = message
    end

    # @return [String]
    def to_s
      "#{file_name}:#{line_number} at #{@color.p(test_name, :yellow)}. #{message}"
    end
  end
end
