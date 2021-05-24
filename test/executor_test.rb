# frozen_string_literal: true

require "test_helper"

class ExecutorTest < Guava::Test
  def setup
    Guava::Executor.any_instance.expects(:populate_queue).returns([[MyTest, :test_example]])
  end

  def test_delegates_methods_to_workers
    MyTest.expects(:run).with(:test_example, {})

    executor = Guava::Executor.new({})
    executor.run

    assert_equal 0, executor.instance_variable_get(:@queue)
  end
end
