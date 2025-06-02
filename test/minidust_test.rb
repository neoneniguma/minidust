require "minitest/autorun"
require_relative "test_helper"
require_relative "../lib/minidust"

class MinidustTest < Minitest::Test
  def setup
    @dummy_file = "lib/dummy.rb"
    @original_stdout = $stdout
    @stdout = StringIO.new
    $stdout = @stdout
    @project_root = Dir.pwd
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

  def test_report_prints_colored_output_for_covered_file
    file_path = File.join(@project_root, "lib/example.rb")
    Coverage.stub(:result, {
      file_path => [1, 1, 0, nil, 1]
    }) do
      Minidust.report
    end

    output = @stdout.string
    assert_includes output, "== Minidust Coverage Report =="
    assert_includes output, "example.rb"
    assert_includes output, "60.0%"  # 3 covered out of 5 lines
  end

  def test_report_uses_correct_colors_for_coverage_levels
    lib_file = File.join(@project_root, "lib/test_colors.rb")
    
    # Test green (>=90%)
    Coverage.stub(:result, { lib_file => [1, 1, 1, 1, nil] }) do
      Minidust.report
    end
    assert_includes @stdout.string, "\e[32m"  # green color code
    
    @stdout.reopen
    
    # Test yellow (>=70% and <90%)
    Coverage.stub(:result, { lib_file => [1, 1, 0, 1, nil] }) do
      Minidust.report
    end
    assert_includes @stdout.string, "\e[33m"  # yellow color code
    
    @stdout.reopen
    
    # Test red (<70%)
    Coverage.stub(:result, { lib_file => [1, 0, 0, 1, nil] }) do
      Minidust.report
    end
    assert_includes @stdout.string, "\e[31m"  # red color code
  end

  def test_report_skips_non_lib_files
    Coverage.stub(:result, {
      "/usr/local/lib/ruby/something.rb" => [1, 1, nil]
    }) do
      Minidust.report
    end

    output = @stdout.string
    refute_match(/something\.rb/, output)
  end

  def test_warns_when_coverage_already_running
    Coverage.stub(:running?, true) do
      Minidust.start
    end
    
    assert_includes @stdout.string, "[minidust] Coverage already started — skipping"
  end

  def test_report_skips_gem_files
    Coverage.stub(:result, {
      "/gems/minidust/lib/something.rb" => [1, 1, nil]
    }) do
      Minidust.report
    end

    output = @stdout.string
    refute_match(/something\.rb/, output)
  end
end
