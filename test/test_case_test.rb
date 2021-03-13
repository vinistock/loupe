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
    Ant::Reporter.any_instance.expects(:increment_success_count)

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

  def test_assert_failure
    Ant::Reporter.any_instance.expects(:increment_assertion_count)
    Ant::Reporter.any_instance.expects(:increment_failure_count)

    assert_raises(Ant::TestCase::AssertionFailed) do
      @test.assert(false)
    end
  end

  def test_assert_match_success
    matcher = /something \d/
    Ant::TestCase.any_instance.expects(:assert_respond_to).with(matcher, :=~)
    Ant::TestCase.any_instance.expects(:assert).with do |equal, msg|
      equal && /Expected .* to match .*\./.match?(msg)
    end

    @test.assert_match(matcher, "something 1")
  end

  def test_assert_match_failure
    matcher = /something \d/
    Ant::TestCase.any_instance.expects(:assert_respond_to).with(matcher, :=~)
    Ant::TestCase.any_instance.expects(:assert).with do |equal, msg|
      !equal && /Expected .* to match .*\./.match?(msg)
    end

    @test.assert_match(matcher, "something")
  end

  def test_assert_match_string
    matcher = "thing 1"
    Ant::TestCase.any_instance.expects(:assert_respond_to).with(matcher, :=~)
    Ant::TestCase.any_instance.expects(:assert).with do |equal, msg|
      equal && /Expected .* to match .*\./.match?(msg)
    end

    @test.assert_match(matcher, "something 1")
  end

  assert_assertion(:assert_equal, [2, 2], [2, 3], /Expected .* to be equal to .*\./)
  assert_assertion(:assert_empty, [[]], [[2]], /Expected .* to be empty\./)
  assert_assertion(:assert_respond_to, ["string", :upcase], [nil, :upcase], /Expected .* to respond to .*\./)
  assert_assertion(:assert_includes, [[1, 2, 3], 2], [[1, 2, 3], 5], /Expected .* to include .*\./)
  assert_assertion(:assert_nil, [nil], ["non-nil"], /Expected .* to be nil\./)
  assert_assertion(:assert_instance_of, [Integer, 1], [String, 1], /Expected .* to be an instance of .*, not .*\./)
  assert_assertion(:assert_kind_of, [Integer, 1], [String, 1], /Expected .* to be a kind of .*, not .*\./)
  assert_assertion(:assert_predicate, [[], :empty?], [[1], :empty?], /Expected .* to be .*\./)
  assert_assertion(:assert_same, %w[same same], %w[same different], /Expected .* to be the same as .*\./)
  assert_assertion(:assert_path_exists, ["lib/ant.rb"], ["fake/path/file.rb"], /Expected path .* to exist\./)
  assert_assertion(:assert_in_delta, [5.0, 5.0001], [5.0, 4.8], /Expected |.* - .*| .* \(.*\) .* to be <= .*\./)
  assert_assertion(:assert_in_epsilon, [5.0, 5.0001], [5.0, 4.8], /Expected |.* - .*| .* \(.*\) .* to be <= .*\./)
end
