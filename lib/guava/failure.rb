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

    # @param file_name [String]
    # @param test_name [String]
    # @param message [String]
    # @param line_number [Integer]
    # @return [Guava::Failure]
    def initialize(file_name, test_name, message, line_number)
      @file_name = file_name
      @test_name = test_name
      @message = message
      @line_number = line_number
    end

    # @return [String]
    def to_s
      "#{file_name}:#{line_number} at #{test_name}. #{message}"
    end
  end
end
