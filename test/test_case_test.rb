# typed: true
# frozen_string_literal: true

require "test_helper"

class TestCaseTest < Minitest::Test # rubocop:disable Metrics/ClassLength
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

    @test.assert_match(matcher, "thing 1")
  end

  def test_refute_match_success
    matcher = /something \d/
    Ant::TestCase.any_instance.expects(:assert_respond_to).with(matcher, :=~)
    Ant::TestCase.any_instance.expects(:refute).with do |equal, msg|
      !equal && /Expected .* to not match .*\./.match?(msg)
    end

    @test.refute_match(matcher, "something asd")
  end

  def test_refute_match_failure
    matcher = /something \d/
    Ant::TestCase.any_instance.expects(:assert_respond_to).with(matcher, :=~)
    Ant::TestCase.any_instance.expects(:refute).with do |equal, msg|
      equal && /Expected .* to not match .*\./.match?(msg)
    end

    @test.refute_match(matcher, "something 1")
  end

  def test_refute_match_string
    matcher = "thing 1"
    Ant::TestCase.any_instance.expects(:assert_respond_to).with(matcher, :=~)
    Ant::TestCase.any_instance.expects(:refute).with do |equal, msg|
      !equal && /Expected .* to not match .*\./.match?(msg)
    end

    @test.refute_match(matcher, "something")
  end

  def test_assert_output_success
    Ant::TestCase.any_instance.expects(:assert_equal).with("blah", "blah")
    Ant::TestCase.any_instance.expects(:assert_equal).with("blorp", "blorp")

    @test.assert_output("blah", "blorp") do
      $stdout.print "blah"
      $stderr.print "blorp"
    end
  end

  def test_assert_output_regex_success
    Ant::TestCase.any_instance.expects(:assert_match).with(/blah\s/, "Blah, blah blah")
    Ant::TestCase.any_instance.expects(:assert_match).with(/, blo/, "Blorp, blorp blorp")

    @test.assert_output(/blah\s/, /, blo/) do
      $stdout.print "Blah, blah blah"
      $stderr.print "Blorp, blorp blorp"
    end
  end

  def test_refute_output_success
    Ant::TestCase.any_instance.expects(:refute_equal).with("blah", "blorp")
    Ant::TestCase.any_instance.expects(:refute_equal).with("blorp", "blah")

    @test.refute_output("blah", "blorp") do
      $stdout.print "blorp"
      $stderr.print "blah"
    end
  end

  def test_refute_output_regex_success
    Ant::TestCase.any_instance.expects(:refute_match).with(/blah\s/, "Blorp, blorp blorp")
    Ant::TestCase.any_instance.expects(:refute_match).with(/, blo/, "Blah, blah blah")

    @test.refute_output(/blah\s/, /, blo/) do
      $stdout.print "Blorp, blorp blorp"
      $stderr.print "Blah, blah blah"
    end
  end

  def test_assert_silent
    Ant::TestCase.any_instance.expects(:assert_output).with("", "")

    @test.assert_silent { nil }
  end

  def test_refute_silent
    Ant::TestCase.any_instance.expects(:refute_output).with("", "")

    @test.refute_silent { nil }
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

  assert_refute(:refute_equal, [2, 3], [2, 2], /Expected .* to not be equal to .*\./)
  assert_refute(:refute_empty, [[2]], [[]], /Expected .* to not be empty\./)
  assert_refute(:refute_respond_to, [nil, :upcase], ["string", :upcase], /Expected .* not to respond to .*\./)
  assert_refute(:refute_includes, [[1, 2, 3], 5], [[1, 2, 3], 2], /Expected .* to not include .*\./)
  assert_refute(:refute_nil, ["non-nill"], [nil], /Expected .* to not be nil\./)
  assert_refute(:refute_instance_of, [String, 1], [Integer, 1], /Expected .* to not be an instance of .*\./)
  assert_refute(:refute_kind_of, [String, 1], [Integer, 1], /Expected .* to not be a kind of .*\./)
  assert_refute(:refute_predicate, [[1], :empty?], [[], :empty?], /Expected .* to not be .*\./)
  assert_refute(:refute_same, %w[same different], %w[same same], /Expected .* to not be the same as .*\./)
  assert_refute(:refute_path_exists, ["fake/path/file.rb"], ["lib/ant.rb"], /Expected path .* to not exist\./)
  assert_refute(:refute_in_delta, [5.0, 4.8], [5.0, 5.0001], /Expected |.* - .*| .* \(.*\) .* to not be <= .*\./)
  assert_refute(:refute_in_epsilon, [5.0, 4.8], [5.0, 5.0001], /Expected |.* - .*| .* \(.*\) .* to not be <= .*\./)
end
