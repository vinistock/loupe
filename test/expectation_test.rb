# frozen_string_literal: true

require "test_helper"

class ExpectationTest < Minitest::Test # rubocop:disable Metrics/ClassLength
  def setup
    @test = MyTest.new(Guava::Reporter.new, :test_example)
  end

  def test_failed_expectation
    expect = Guava::Expectation.new(false, @test)
    @test
      .reporter
      .expects(:increment_failure_count)
      .with(@test.file, @test.name, @test.line_number, "Expected false to be truthy.", MyTest)

    assert_raises(Guava::Expectation::ExpectationFailed) do
      expect.to_be_truthy
    end
  end

  def test_to_be_truthy
    expect_with(true, /Expected .* to be .*truthy.*\./).to_be_truthy
  end

  def test_to_be_falsey
    expect_with(false, /Expected .* to be .*falsey.*\./).to_be_falsey
  end

  def test_to_be_equal_to
    expect_with(10, /Expected .*10.* to be equal to .*10.*\./).to_be_equal_to(10)
  end

  def test_to_not_be_equal_to
    expect_with(10, /Expected .*10.* to not be equal to .*11.*\./).to_not_be_equal_to(11)
  end

  def test_to_be_empty
    expect_with([], /Expected .*\[\].* to be empty\./).to_be_empty
  end

  def test_to_not_be_empty
    expect_with([1, 2, 3], /Expected .*\[1, 2, 3\].* to not be empty\./).to_not_be_empty
  end

  def test_to_respond_to
    expect_with("Ruby", /Expected .*Ruby.* to respond to upcase\./).to_respond_to(:upcase)
  end

  def test_to_not_respond_to
    expect_with("Ruby", /Expected .*Ruby.* to not respond to post\./).to_not_respond_to(:post)
  end

  def test_to_include
    expect_with([1], /Expected .*\[1\].* to include .*1.*\./).to_include(1)
  end

  def test_to_not_include
    expect_with([1], /Expected .*\[1\].* to not include .*2.*\./).to_not_include(2)
  end

  def test_to_be_nil
    expect_with(nil, /Expected nil to be nil\./).to_be_nil
  end

  def test_to_not_be_nil
    expect_with(1, /Expected .*1.* to not be nil\./).to_not_be_nil
  end

  def test_to_be_an_instance_of
    expect_with(1, /Expected .*1.* to be an instance of .*Integer.*\./).to_be_an_instance_of(Integer)
  end

  def test_to_not_be_an_instance_of
    expect_with(1, /Expected .*1.* to not be an instance of .*String.*\./).to_not_be_an_instance_of(String)
  end

  def test_to_be_a_kind_of
    expect_with("Ruby", /Expected .*Ruby.* to be a kind of .*String.*\./).to_be_a_kind_of(String)
  end

  def test_to_not_be_a_kind_of
    expect_with("Ruby", /Expected .*Ruby.* to not be a kind of .*Integer.*\./).to_not_be_a_kind_of(Integer)
  end

  def test_to_be
    expect_with([], /Expected .*\[\].* to be empty\?\./).to_be(:empty?)
  end

  def test_to_not_be
    expect_with([1], /Expected .*\[1\].* to not be empty\?\./).to_not_be(:empty?)
  end

  def test_to_match
    expect = Guava::Expectation.new(/abc/, @test)
    expect.expects(:assert).with do |value, message|
      value && %r{Expected .*/abc/.* to respond to =~\.}.match?(message)
    end
    expect.expects(:assert).with do |value, message|
      value && %r{Expected .*/abc/.* to match abcdef\.}.match?(message)
    end

    expect.to_match("abcdef")
  end

  def test_to_match_using_string
    expect = Guava::Expectation.new("abc", @test)
    expect.expects(:assert).with do |value, message|
      value && /Expected .*abc.* to respond to =~\./.match?(message)
    end
    expect.expects(:assert).with do |value, message|
      value && /Expected .*abc.* to match abc\./.match?(message)
    end

    expect.to_match("abc")
  end

  def test_to_not_match
    expect = Guava::Expectation.new(/xyz/, @test)
    expect.expects(:assert).with do |value, message|
      value && %r{Expected .*/xyz/.* to respond to =~\.}.match?(message)
    end
    expect.expects(:assert).with do |value, message|
      value && %r{Expected .*/xyz/.* to not match abcdef\.}.match?(message)
    end

    expect.to_not_match("abcdef")
  end

  def test_to_not_match_using_string
    expect = Guava::Expectation.new("xyz", @test)
    expect.expects(:assert).with do |value, message|
      value && /Expected .*xyz.* to respond to =~\./.match?(message)
    end
    expect.expects(:assert).with do |value, message|
      value && /Expected .*xyz.* to not match abcdef\./.match?(message)
    end

    expect.to_not_match("abcdef")
  end

  def test_to_be_the_same_as
    object = Object.new

    expect_with(
      object,
      /Expected #{object.inspect}.* to be the same as #{object.inspect}.*\./
    ).to_be_the_same_as(object)
  end

  def test_to_not_be_the_same_as
    object = Object.new
    another_object = Object.new

    expect_with(
      object,
      /Expected #{object.inspect}.* to not be the same as #{another_object.inspect}.*\./
    ).to_not_be_the_same_as(another_object)
  end

  def test_to_be_an_existing_path
    expect_with(
      "Gemfile",
      /Expected path .*Gemfile.* to exist\./
    ).to_be_an_existing_path
  end

  def test_to_not_be_an_existing_path
    expect_with(
      "fakepath",
      /Expected path .*fakepath.* to not exist\./
    ).to_not_be_an_existing_path
  end

  def test_to_be_in_delta_of
    expect_with(
      5.0,
      /Expected |5.0 - 5.1| \(.*0\.1.*\) to be <= .*0.2.*\./
    ).to_be_in_delta_of(5.1, 0.2)
  end

  def test_to_not_be_in_delta_of
    expect_with(
      5.0,
      /Expected |5.0 - 5.1| \(.*0\.1.*\) to not be <= .*0.001.*\./
    ).to_not_be_in_delta_of(5.1)
  end

  def test_to_be_in_epsilon_of
    expect_with(
      5.0,
      /Expected |5.0 - 5.1| \(.*0\.1.*\) to be <= .*0.1.*\./
    ).to_be_in_epsilon_of(5.1, 0.1)
  end

  def test_to_not_be_in_epsilon_of
    expect_with(
      5.0,
      /Expected |5.0 - 5.1| \(.*0\.1.*\) to not be <= .*0.01.*\./
    ).to_not_be_in_epsilon_of(5.1, 0.01)
  end

  def test_to_satisfy_opeartor
    expect_with(
      5.0,
      /Expected .*5.0.* to be < .*5.1.*\./
    ).to_satisfy_operator(:<, 5.1)
  end

  def test_to_not_satisfy_opeartor
    expect_with(
      5.0,
      /Expected .*5.0.* to not be > .*5.1.*\./
    ).to_not_satisfy_operator(:>, 5.1)
  end

  private

  def expect_with(target, regex)
    expect = Guava::Expectation.new(target, @test)
    expect.expects(:assert).with do |value, message|
      value && regex.match?(message)
    end

    expect
  end
end
