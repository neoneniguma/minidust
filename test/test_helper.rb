require 'minitest/autorun'
require 'minitest/pride'
require 'stringio'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minidust'

# Minidust.enable!

# require 'minitest/mock'

require 'mocha/minitest'

class MinitestWithStdoutCapture < Minitest::Test
  def capture_stdout
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end
end
