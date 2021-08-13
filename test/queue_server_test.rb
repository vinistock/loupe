# frozen_string_literal: true

require "test_helper"

class QueueServerTest < Minitest::Test
  def setup
    @queue = [[MyTest, :test_example]]
    @reporter = Loupe::PlainReporter.new
    @server = Loupe::QueueServer.new(@queue, @reporter)
  end

  def test_add_reporter
    tmp_reporter = Loupe::PlainReporter.new
    tmp_reporter.increment_expectation_count

    @server.add_reporter(tmp_reporter)
    assert_equal 1, @reporter.expectation_count
  end

  def test_pop
    assert_equal(
      [MyTest, :test_example],
      @server.pop
    )
  end

  def test_length
    assert_equal 1, @server.length
  end

  def test_empty
    refute_predicate @server, :empty?
    @server.pop
    assert_predicate @server, :empty?
  end
end
