require 'test_helper'

class UnusedMethodsReporterTest < MinitestWithStdoutCapture
  class DummyClass; end

  def test_reports_no_unused_methods_when_empty
    reporter = Minidust::UnusedMethodsReporter.new({})
    
    output = capture_stdout do
      reporter.report
    end

    assert_empty output
  end

  def test_reports_no_unused_methods_when_all_used
    methods_coverage = {
      [DummyClass, :method1, 1, 1, 1, 1] => 1,
      [DummyClass, :method2, 2, 2, 2, 2] => 2
    }
    reporter = Minidust::UnusedMethodsReporter.new(methods_coverage)
    
    output = capture_stdout do
      reporter.report
    end

    assert_empty output
  end

  def test_reports_unused_methods
    methods_coverage = {
      [DummyClass, :used_method, 1, 1, 1, 1] => 1,
      [DummyClass, :unused_method, 2, 2, 2, 2] => 0
    }
    reporter = Minidust::UnusedMethodsReporter.new(methods_coverage)
    
    output = capture_stdout do
      reporter.report
    end

    assert_match(/Unused Methods/, output)
    assert_match(/DummyClass#unused_method/, output)
    assert_match(/line 2/, output)
    refute_match(/used_method/, output)
  end

  def test_reports_multiple_unused_methods
    methods_coverage = {
      [DummyClass, :unused1, 1, 1, 1, 1] => 0,
      [DummyClass, :unused2, 2, 2, 2, 2] => 0,
      [DummyClass, :used_method, 3, 3, 3, 3] => 1
    }
    reporter = Minidust::UnusedMethodsReporter.new(methods_coverage)
    
    output = capture_stdout do
      reporter.report
    end

    assert_match(/Unused Methods/, output)
    assert_match(/DummyClass#unused1.*line 1/m, output)
    assert_match(/DummyClass#unused2.*line 2/m, output)
    refute_match(/used_method/, output)
  end

  def test_formats_object_method_names
    methods_coverage = {
      [Object, :unused_method, 1, 1, 1, 1] => 0
    }
    reporter = Minidust::UnusedMethodsReporter.new(methods_coverage)
    
    output = capture_stdout do
      reporter.report
    end

    assert_match(/• unused_method \(defined on line 1\)/, output)
    refute_match(/Object#unused_method/, output)
  end

  def test_formats_class_method_names
    methods_coverage = {
      [DummyClass, :unused_method, 1, 1, 1, 1] => 0
    }
    reporter = Minidust::UnusedMethodsReporter.new(methods_coverage)
    
    output = capture_stdout do
      reporter.report
    end

    assert_match(/• DummyClass#unused_method \(defined on line 1\)/, output)
  end
end 