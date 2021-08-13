# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "loupe"
require "minitest/autorun"
require "purdytest"
require "mocha/minitest"
require "byebug"

class MyTest < Loupe::Test
  def test_example
    expect(true).to_be_truthy
  end
end

def capture_output
  new_stdout = StringIO.new
  new_stderr = StringIO.new
  stdout = $stdout
  stderr = $stderr
  $stdout = new_stdout
  $stderr = new_stderr

  yield

  [new_stdout.string, new_stderr.string]
ensure
  $stdout = stdout
  $stderr = stderr
end
