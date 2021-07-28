# frozen_string_literal: true

require "test_helper"

class TestTest < Minitest::Test
  def setup
    @test = MyTest.new(Loupe::Reporter.new, :test_example)
  end

  def test_inheriting_tests
    assert_includes(Loupe::Test.classes, MyTest)
  end

  def test_class_run
    MyTest.any_instance.expects(:before)
    MyTest.any_instance.expects(:test_example)
    MyTest.any_instance.expects(:after)
    Loupe::Reporter.any_instance.expects(:increment_success_count)

    MyTest.run(:test_example)
  end

  def test_setup_exists
    assert_respond_to @test, :before
  end

  def test_teardown_exists
    assert_respond_to @test, :after
  end
end
