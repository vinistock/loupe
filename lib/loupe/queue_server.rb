# frozen_string_literal: true

module Loupe
  # Server
  #
  # This object is the one passed to DRb in order to
  # communicate between worker and server processes and coordinate
  # both the queue and the reporting results
  class QueueServer
    # The two operations we need to synchronize between the
    # main process and its children is the queue and the reporter.
    # We need to share the queue, so that workers can pop the tests from it
    # and we need to share the reporter, so that workers can update the results
    #
    # @param queue [Array<Array<Class, Symbol>>]
    # @param reporter [Loupe::Reporter]
    # @return [Loupe::Server]
    def initialize(queue, reporter)
      @queue = queue
      @reporter = reporter
    end

    # add_reporter
    #
    # Adds a temporary reporter from a child process into
    # the main reporter to aggregate results
    #
    # @param other [Loupe::Reporter]
    # @return [void]
    def add_reporter(other)
      @reporter << other
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
