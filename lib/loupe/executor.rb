# frozen_string_literal: true

module Loupe
  # Executor
  #
  # This abstract parent class is responsible for providing the basics
  # for executors. Concrete classes are the process and ractor executors.
  class Executor
    # @param options [Hash<Symbol, BasicObject>]
    # @return [Loupe::Executor]
    def initialize(options)
      @options = options
      @queue = populate_queue
      @reporter = options[:interactive] ? PagedReporter.new(options) : PlainReporter.new(options)
    end

    # @return [Integer]
    def run
      raise NotImplementedError, "Concrete implementations of executors should implement the run method"
    end

    private

    # Populate the test queue with entries including
    # the class and the test method to be executed.
    # E.g.:
    #   [[MyTest, :test_something], [AnotherTest, :test_another_thing]]
    #
    # @return [Array<Array<Class, Symbol>>]
    def populate_queue
      Test.classes.flat_map do |klass, line_numbers|
        list = klass.test_list

        unless line_numbers.empty?
          list.select! do |method_name|
            line_numbers.include?(klass.instance_method(method_name).source_location.last.to_s)
          end
        end

        list.map! { |method| [klass, method] }.shuffle!
      end
    end
  end
end
