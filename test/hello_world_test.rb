require "minitest/autorun"
require_relative "test_helper"
require_relative "../lib/hello_world"

class TestHello < Minitest::Test
  def test_hello
    assert_output("Hello, Marium!\n") { hello("Marium") }
  end
end