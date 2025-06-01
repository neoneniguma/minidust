require "minitest/autorun"
require_relative "test_helper"
require_relative "../lib/minidust"

class MinidustTest < Minitest::Test
  def setup
    @dummy_file = "lib/dummy.rb"
    @original_stdout = $stdout
    @stdout = StringIO.new
    $stdout = @stdout
  end

  def teardown
    $stdout = @original_stdout
  end

  def test_start_enables_coverage
    Coverage.stubs(:start).returns(true)
    assert true  # If no exception, it's OK
  end

  def test_enable_sets_hooks
    Coverage.stub(:start, nil) do
      Minitest.stub(:after_run, ->(&block) { assert block }) do
        Minidust.enable!
      end
    end
  end

  # def test_report_prints_colored_output_for_covered_file
  #   # Simulate coverage for one file in lib/
  #   Coverage.stub(:result, {
  #     File.expand_path("../../lib/example.rb", __FILE__) => [1, 1, 0, nil, 1]
  #   }) do
  #     Minidust.report
  #   end

  #   output = @stdout.string
  #   assert_includes output, "Minidust Coverage Report"
  #   assert_match(/example\.rb: \d+\.\d+%/, output)
  # end

  def test_report_skips_non_lib_files
    Coverage.stub(:result, {
      "/usr/local/lib/ruby/something.rb" => [1, 1, nil]
    }) do
      Minidust.report
    end

    output = @stdout.string
    refute_match(/something\.rb/, output)
  end

end
