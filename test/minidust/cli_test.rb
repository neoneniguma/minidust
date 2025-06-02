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
    assert_includes output, "Usage: Minidust <test_file>"
  end

  def test_cli_checks_file_existence
    exit_code = Minidust::CLI.start(["nonexistent_file.rb"]) rescue 1
    output = @stdout.string
    
    assert_equal 1, exit_code
    assert_includes output, "File notfound: nonexistent_file.rb"
  end

  def test_cli_enables_minidust_for_valid_file
    Minidust.expects(:enable!)
    
    # Stub load to prevent actual file execution
    Kernel.stub(:load, nil) do
      Minidust::CLI.start([@test_file])
    end
    
    output = @stdout.string
    assert_includes output, "Running #{@test_file} with Minidust enabled..."
    assert_includes output, "Minidust CLI starting with args:"
  end

  def test_cli_loads_test_file
    file_loaded = false
    
    Minidust.stub(:enable!, nil) do
      Kernel.stub(:load, ->(_) { file_loaded = true }) do
        Minidust::CLI.start([@test_file])
      end
    end
    
    assert file_loaded, "Test file should be loaded"
  end

  def test_cli_expands_file_path
    expanded_path = nil
    
    Minidust.stub(:enable!, nil) do
      Kernel.stub(:load, ->(path) { expanded_path = path }) do
        Minidust::CLI.start([@test_file])
      end
    end
    
    assert_equal File.expand_path(@test_file), expanded_path
  end
end 