# frozen_string_literal: true

require "etc"

module Loupe
  # Executor
  #
  # This class is responsible for the execution flow. It populates
  # the queue of tests to be executed, instantiates the workers,
  # creates an accumulator reporter and delegates tests to workers
  # until the queue is empty.
  class Executor
    # @param options [Hash<Symbol, BasicObject>]
    # @return [Loupe::Executor]
    def initialize(options)
      @queue = populate_queue
      @reporter = options[:interactive] ? PagedReporter.new(options) : PlainReporter.new(options)
      @workers = (0...[Etc.nprocessors, @queue.length].min).map do
        Ractor.new(options) do |opts|
          loop do
            klass, method_name = Ractor.receive
            Ractor.yield klass.run(method_name, opts)
          end
        end
      end
    end

    # Run the main process for executing tests
    #
    # Send the first tests to all workers from the queue and
    # then keep selecting the idle Ractor until the queue is empty.
    # Acumulate the reporters as tests are finalized.
    # The last set of results are obtained outside the loop using `take`,
    # since once the queue is empty `select` will no longer accumulate the result.
    #
    # @return [Integer]
    def run
      @workers.each do |r|
        item = @queue.pop
        r.send(item) unless item.nil?
      end

      until @queue.empty?
        idle_worker, tmp_reporter = Ractor.select(*@workers)
        @reporter += tmp_reporter
        idle_worker.send(@queue.pop)
      end

      @workers.each { |w| @reporter += w.take }

      @reporter.print_summary
      @reporter.exit_status
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
