$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "minidust"

require "minitest/autorun"

require "minidust"
Minidust.start

Minitest.after_run do
  Minidust.report
end
