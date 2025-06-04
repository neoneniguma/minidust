require "minitest/autorun"
require_relative "test_helper"
require_relative "../lib/minidust"

class MinidustTest < MinitestWithStdoutCapture
  def setup
    @project_root = Dir.pwd
    # Save original config file if it exists
    @config_file = File.join(@project_root, '.minidust.yml')
    @original_config = File.exist?(@config_file) ? File.read(@config_file) : nil
  end

  def teardown
    # Restore original config file
    if @original_config
      File.write(@config_file, @original_config)
    else
      File.delete(@config_file) if File.exist?(@config_file)
    end
  end

  def test_start_enables_coverage
    Coverage.stubs(:start).returns(true)
    Minidust.start
    assert true  # If no exception, it's OK
  end

  def test_enable_sets_hooks
    Coverage.stub(:start, nil) do
      Minitest.stub(:after_run, ->(&block) { assert block }) do
        Minidust.enable!
      end
    end
  end

  def test_warns_when_coverage_already_running
    Coverage.stub(:running?, true) do
      output = capture_stdout do
        Minidust.start
      end
      assert_includes output, "[minidust] Coverage already started — skipping"
    end
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

  def test_report_filters_non_project_files
    non_project_file = "/usr/local/lib/ruby/something.rb"
    gem_file = "/gems/minidust/lib/something.rb"
    project_file = File.join(@project_root, "lib/example.rb")
    
    Coverage.stub(:result, {
      non_project_file => [1, 1, nil],
      gem_file => [1, 1, nil],
      project_file => [1, 1, 1]
    }) do
      output = capture_stdout do
        Minidust.report
      end
      
      refute_match(/\/usr\/local\/lib\/ruby\/something\.rb/, output)
      refute_match(/\/gems\/minidust\/lib\/something\.rb/, output)
      assert_match(/lib\/example\.rb/, output)
    end
  end

  def test_report_respects_configuration_paths
    config = {
      'include_paths' => ['src/'],
      'exclude_paths' => ['src/excluded/']
    }
    File.write(@config_file, config.to_yaml)

    included_file = File.join(@project_root, "src/example.rb")
    excluded_file = File.join(@project_root, "src/excluded/example.rb")
    non_included_file = File.join(@project_root, "lib/example.rb")
    
    Coverage.stub(:result, {
      included_file => [1, 1, 1],
      excluded_file => [1, 1, 1],
      non_included_file => [1, 1, 1]
    }) do
      output = capture_stdout do
        Minidust.report
      end
      
      assert_match(/src\/example\.rb/, output)
      refute_match(/src\/excluded\/example\.rb/, output)
      refute_match(/lib\/example\.rb/, output)
    end
  end
end
