require "minitest/autorun"
require_relative "../test_helper"
require_relative "../../lib/minidust/cli"

class MinidustCLITest < Minitest::Test
  def setup
    @original_stdout = $stdout
    @stdout = StringIO.new
    $stdout = @stdout
    
    # Create a temporary test file
    @test_file = "tmp_test_file.rb"
    File.write(@test_file, "puts 'test content'")
  end

  def teardown
    $stdout = @original_stdout
    File.delete(@test_file) if File.exist?(@test_file)
  end

  def test_cli_requires_arguments
    exit_code = Minidust::CLI.start([]) rescue 1
    output = @stdout.string
    
    assert_equal 1, exit_code
    assert_includes output, "Usage: minidust <test_file>"
  end

  def test_cli_checks_file_existence
    exit_code = Minidust::CLI.start(["nonexistent_file.rb"]) rescue 1
    output = @stdout.string
    
    assert_equal 1, exit_code
    assert_includes output, "File notfound: nonexistent_file.rb"
  end

  def test_cli_enables_minidust_for_valid_file
    Minidust.expects(:enable!)
    
    # Stub require to prevent actual file execution
    Kernel.stub(:require, nil) do
      Minidust::CLI.start([@test_file])
    end
    
    output = @stdout.string
    assert_includes output, "Running #{@test_file} with Minidust enabled..."
  end

  def test_cli_loads_test_file
    file_loaded = false
    absolute_path = File.expand_path(@test_file)
    
    Minidust.stub(:enable!, nil) do
      Kernel.stub(:require, ->(path) { 
        file_loaded = true
        assert_equal absolute_path, path, "Should load using absolute path"
      }) do
        Minidust::CLI.start([@test_file])
      end
    end
    
    assert file_loaded, "Test file should be loaded"
  end

  def test_cli_handles_multiple_test_files
    files = ["test1.rb", "test2.rb"]
    loaded_files = []
    
    # Create temporary test files
    files.each do |file|
      File.write(file, "puts 'test content'")
    end

    begin
      Minidust.stub(:enable!, nil) do
        Kernel.stub(:require, ->(path) { loaded_files << path }) do
          Minidust::CLI.start(files)
        end
      end

      assert_equal files.map { |f| File.expand_path(f) }, loaded_files,
        "Should load all test files using absolute paths"
    ensure
      # Clean up temporary files
      files.each { |f| File.delete(f) if File.exist?(f) }
    end
  end
end 