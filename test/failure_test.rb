# frozen_string_literal: true

require "test_helper"

class FailureTest < Minitest::Test
  def setup
    @test = MyTest.new(Loupe::Reporter.new, :test_example)
    @failure = Loupe::Failure.new(@test, "Expected something to be truthy")
  end

  def test_to_s
    assert_match(
      %r{.*/loupe/test/test_helper\.rb:11 at test_example\. Expected something to be truthy},
      @failure.to_s
    )
  end

  def test_location_and_message
    location, message = @failure.location_and_message
    assert_match(
      %r{.*/loupe/test/test_helper\.rb:11 at test_example},
      location
    )

    assert_equal("Expected something to be truthy", message)
  end
end
