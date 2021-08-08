# frozen_string_literal: true

require "etc"
require "drb/drb"

module Loupe
  # ProcessExecutor
  #
  # This class is responsible for executing tests in process mode.
  class ProcessExecutor < Executor
    # @param options [Hash<Symbol, BasicObject>]
    # @return [Loupe::Executor]
    def initialize(options)
      super

      @server = Server.new(populate_queue, @reporter)
      @url = DRb.start_service("drbunix:", @server).uri
    end

    # @return [Integer]
    def run
      @workers = (0...[Etc.nprocessors, @server.length].min).map do
        fork do
          DRb.start_service
          server = DRbObject.new_with_uri(@url)

          until server.empty?
            klass, method_name = server.pop
            server.add_reporter(klass.run(method_name, @options))
          end
        end
      end

      @reporter.print_summary
      @reporter.exit_status
    ensure
      shutdown
    end

    private

    # return [void]
    def shutdown
      @workers.each { |pid| Process.waitpid(pid) }
      DRb.stop_service
    end
  end

  # Server
  #
  # This object is the one passed to DRb in order to
  # communicate between worker and server processes and coordinate
  # both the queue and the reporting results
  class Server
    # @param queue [Array<Array<Class, Symbol>>]
    # @param reporter [Loupe::Reporter]
    # @return [Loupe::Server]
    def initialize(queue, reporter)
      @queue = queue
      @reporter = reporter
    end

    # @param other [Loupe::Reporter]
    # @return [void]
    def add_reporter(other)
      @reporter += other
    end

    # @return [Array<Class, Symbol>]
    def pop
      @queue.pop
    end

    # @return [Integer]
    def length
      @queue.length
    end

    # @return [Boolean]
    def empty?
      @queue.empty?
    end
  end
end
