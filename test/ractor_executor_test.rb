# frozen_string_literal: true

require "test_helper"

class RactorExecutorTest < Minitest::Test
  def setup
    Loupe::Executor.any_instance.expects(:populate_queue).returns([[MyTest, :test_example]]).at_least_once
    @executor = Loupe::RactorExecutor.new(interactive: false)
  end

  def test_run
    capture_output do
      assert_equal 0, @executor.run
    end

    assert_equal 0, @executor.instance_variable_get(:@queue).length
  end

  def test_run_output
    stdout, _stderr = capture_output { @executor.run }

    assert_match("Tests: 1 Expectations: 1", stdout)
    assert_match("Passed: 1 Failures: 0", stdout)
    assert_match(/Finished in .* seconds/, stdout)
  end
end
