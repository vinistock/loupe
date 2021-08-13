# frozen_string_literal: true

require "drb/drb"

module Loupe
  # ProcessExecutor
  #
  # This class is responsible for executing tests in process mode.
  class ProcessExecutor < Executor
    # Create a new ProcessExecutor
    #
    # This will create a new server object that will be shared
    # with child processes using DRb
    # @param options [Hash<Symbol, BasicObject>]
    # @return [Loupe::Executor]
    def initialize(options)
      super

      @server = QueueServer.new(populate_queue, @reporter)
      @url = DRb.start_service("drbunix:", @server).uri
    end

    # run
    #
    # Fork each one of the process workers and connect with the server
    # object coming from DRb. Run until the queue is clear
    # @return [Integer]
    def run
      @workers = (0...[Etc.nprocessors, @server.length].min).map do
        fork do
          DRb.start_service
          server = DRbObject.new_with_uri(@url)

          until server.empty?
            klass, method_name = server.pop
            server.add_reporter(klass.run(method_name, @options)) if klass && method_name
          end
        end
      end

      shutdown
      @reporter.print_summary
      @reporter.exit_status
    end

    private

    # Wait until all child processes finish executing tests
    # and then stop the DRb service
    # return [void]
    def shutdown
      @workers.each { |pid| Process.waitpid(pid) }
      DRb.stop_service
    end
  end
end
