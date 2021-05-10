# frozen_string_literal: true

require "bundler/setup"
require "active_support"
require "active_support/test_case"
require "active_support/testing/autorun"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
  end
end
