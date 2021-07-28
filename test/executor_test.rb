# frozen_string_literal: true

require "test_helper"

class ExecutorTest < Loupe::Test
  def setup
    Loupe::Executor.any_instance.expects(:populate_queue).returns([[MyTest, :test_example]])
  end

  def test_delegates_methods_to_workers
    MyTest.expects(:run).with(:test_example, {})

    executor = Loupe::Executor.new({})
    executor.run

    assert_equal 0, executor.instance_variable_get(:@queue)
  end
end
