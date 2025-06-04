require 'test_helper'

class CoverageReporterTest < MinitestWithStdoutCapture
  def setup
    @file = "example.rb"
  end

  def test_reports_full_coverage
    lines_coverage = [1, 2, 1] # All lines are covered
    reporter = Minidust::CoverageReporter.new(lines_coverage)

    output = capture_stdout do
      reporter.report(@file)
    end

    assert_match(/🏎️.*example\.rb: 100\.0% \(3\/3\)/, output)
    refute_match(/Unused Lines/, output)
  end

  def test_reports_partial_coverage
    lines_coverage = [1, 0, 1] # One line uncovered
    reporter = Minidust::CoverageReporter.new(lines_coverage)

    output = capture_stdout do
      reporter.report(@file)
    end

    assert_match(/⚠️.*example\.rb: 66\.67% \(2\/3\)/, output)
    assert_match(/Unused Lines/, output)
    assert_match(/Line 2/, output)
  end

  def test_reports_poor_coverage
    lines_coverage = [0, 0, 1] # Most lines uncovered
    reporter = Minidust::CoverageReporter.new(lines_coverage)

    output = capture_stdout do
      reporter.report(@file)
    end

    assert_match(/💥.*example\.rb: 33\.33% \(1\/3\)/, output)
    assert_match(/Unused Lines/, output)
    assert_match(/Line 1/, output)
    assert_match(/Line 2/, output)
  end

  def test_handles_nil_coverage
    lines_coverage = [1, nil, 1] # Line that isn't executable (like comments)
    reporter = Minidust::CoverageReporter.new(lines_coverage)

    output = capture_stdout do
      reporter.report(@file)
    end

    assert_match(/🏎️.*example\.rb: 100\.0% \(2\/2\)/, output)
    refute_match(/Unused Lines/, output)
  end

  def test_color_determination
    reporter = Minidust::CoverageReporter.new([])
    
    assert_equal Minidust::COLORS[:green], reporter.send(:determine_color, 90)
    assert_equal Minidust::COLORS[:green], reporter.send(:determine_color, 100)
    assert_equal Minidust::COLORS[:yellow], reporter.send(:determine_color, 70)
    assert_equal Minidust::COLORS[:red], reporter.send(:determine_color, 69)
  end

  def test_color_key_determination
    reporter = Minidust::CoverageReporter.new([])
    
    assert_equal :green, reporter.send(:determine_color_key, 90)
    assert_equal :green, reporter.send(:determine_color_key, 100)
    assert_equal :yellow, reporter.send(:determine_color_key, 70)
    assert_equal :red, reporter.send(:determine_color_key, 69)
  end
end 