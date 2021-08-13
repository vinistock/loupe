# frozen_string_literal: true

require "loupe/version"
require "loupe/color"
require "loupe/expectation"
require "loupe/test"
require "loupe/failure"
require "loupe/reporter"
require "loupe/executor"
require "loupe/cli"

module Loupe # :nodoc:
  autoload :PlainReporter, "loupe/plain_reporter"
  autoload :PagedReporter, "loupe/paged_reporter"
  autoload :QueueServer, "loupe/queue_server"
  autoload :ProcessExecutor, "loupe/process_executor"
  autoload :RactorExecutor, "loupe/ractor_executor"
end
