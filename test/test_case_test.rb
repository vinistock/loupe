# typed: true
# frozen_string_literal: true

require "test_helper"

class TestCaseTest < Minitest::Test
  def setup
    @test = MyTest.new(Ant::Reporter.new, :test_example)
  end

  def test_inheriting_tests
    assert_includes(Ant::TestCase.classes, MyTest)
  end

  def test_class_run
    MyTest.any_instance.expects(:setup)
    MyTest.any_instance.expects(:test_example)
    MyTest.any_instance.expects(:teardown)

    MyTest.run
  end

  def test_setup_exists
    assert_respond_to @test, :setup
  end

  def test_teardown_exists
    assert_respond_to @test, :teardown
  end

  def test_assert_success
    Ant::Reporter.any_instance.expects(:increment_assertion_count)
    @test.assert(true)
  end

  def test_failure_success
    Ant::Reporter.any_instance.expects(:increment_assertion_count)
    Ant::Reporter.any_instance.expects(:increment_failure_count)

    assert_raises(Ant::TestCase::AssertionFailed) do
      @test.assert(false)
    end
  end
end
