# frozen_string_literal: true

require "test_helper"

class ExecutorTest < Minitest::Test
  def setup
    Loupe::Executor.any_instance.expects(:populate_queue).returns([[MyTest, :test_example]])
  end

  def test_selects_paged_reporter_when_interactive
    executor = Loupe::Executor.new(interactive: true)
    assert_instance_of Loupe::PagedReporter, executor.instance_variable_get(:@reporter)
  end

  def test_selects_plain_reporter_when_plain
    executor = Loupe::Executor.new(interactive: false)
    assert_instance_of Loupe::PlainReporter, executor.instance_variable_get(:@reporter)
  end
end
