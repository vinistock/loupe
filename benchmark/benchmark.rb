# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"
  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "benchmark-ips"
  gem "minitest"
  gem "thor"
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ant"
require "minitest"

class Mini < Minitest::Test # :nodoc:
  def test_benchmark
    assert(true)
  end
end

class AntExample < Ant::TestCase # :nodoc:
  def test_benchmark
    assert(true)
  end
end

mini_reporter = Minitest::ProgressReporter.new(StringIO.new)
ant_reporter = Ant::Reporter.new(StringIO.new)

Benchmark.ips do |x|
  x.report("ant") { AntExample.run([], ant_reporter) }
  x.report("mini") { Mini.run(mini_reporter) }
  x.compare!
end
