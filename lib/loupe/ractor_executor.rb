# frozen_string_literal: true

module Loupe
  # RactorExecutor
  #
  # This class is responsible for the execution flow. It populates
  # the queue of tests to be executed, instantiates the workers,
  # creates an accumulator reporter and delegates tests to workers
  # until the queue is empty.
  class RactorExecutor < Executor
    # @param options [Hash<Symbol, BasicObject>]
    # @return [Loupe::Executor]
    def initialize(options)
      super
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
  end
end
