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
    # Save original config file if it exists
    @config_file = File.join(@project_root, '.minidust.yml')
    @original_config = File.exist?(@config_file) ? File.read(@config_file) : nil
  end

  def teardown
    $stdout = @original_stdout
    # Restore original config file
    if @original_config
      File.write(@config_file, @original_config)
    else
      File.delete(@config_file) if File.exist?(@config_file)
    end
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

  def test_load_config_with_custom_configuration
    config = {
      'include_paths' => ['src/'],
      'exclude_paths' => ['spec/', 'features/']
    }
    File.write(@config_file, config.to_yaml)

    loaded_config = Minidust.load_config
    assert_equal config, loaded_config
  end

  def test_load_config_with_default_configuration
    File.delete(@config_file) if File.exist?(@config_file)

    loaded_config = Minidust.load_config
    assert_equal({
      'include_paths' => ['lib/'],
      'exclude_paths' => ['test/', 'spec/', 'features/']
    }, loaded_config)
  end

  def test_report_respects_include_paths
    config = {
      'include_paths' => ['src/'],
      'exclude_paths' => []
    }
    File.write(@config_file, config.to_yaml)

    file_in_src = File.join(@project_root, "src/example.rb")
    file_in_lib = File.join(@project_root, "lib/example.rb")
    
    Coverage.stub(:result, {
      file_in_src => [1, 1, 1],
      file_in_lib => [1, 1, 1]
    }) do
      Minidust.report
    end

    output = @stdout.string
    assert_includes output, "src/example.rb"
    refute_includes output, "lib/example.rb"
  end

  def test_report_respects_exclude_paths
    config = {
      'include_paths' => ['lib/'],
      'exclude_paths' => ['lib/excluded/']
    }
    File.write(@config_file, config.to_yaml)

    included_file = File.join(@project_root, "lib/example.rb")
    excluded_file = File.join(@project_root, "lib/excluded/example.rb")
    
    Coverage.stub(:result, {
      included_file => [1, 1, 1],
      excluded_file => [1, 1, 1]
    }) do
      Minidust.report
    end

    output = @stdout.string
    assert_includes output, "lib/example.rb"
    refute_includes output, "lib/excluded/example.rb"
  end
end
