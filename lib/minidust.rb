# encoding: utf-8
require "coverage"
require "byebug"
require "minitest"   
require "yaml"

require_relative "minidust/cli"
require_relative "minidust/coverage_reporter"
require_relative "minidust/unused_methods_reporter"

module Minidust
    COLORS = {
    red:    "\e[31m",
    green:  "\e[32m",
    yellow: "\e[33m",
    blue:   "\e[34m",
    reset:  "\e[0m"
  }

  EMOJIS = {
    red:    "💥",    # explosion for poor coverage
    green:  "🏎️",    # racecar for great coverage
    yellow: "⚠️",    # warning for moderate coverage
  }

  # Use Dir.pwd to get the current project directory
  ROOT_DIR = Dir.pwd

  def self.load_config
    config_file = File.join(ROOT_DIR, '.minidust.yml')
    if File.exist?(config_file)
      YAML.load_file(config_file)
    else
      # Default configuration
      {
        'include_paths' => ['lib/'],
        'exclude_paths' => ['test/', 'spec/', 'features/']
      }
    end
  end

  def self.enable!
    start
    begin
      Minitest.after_run { report }
    rescue NameError
      warn "Minitest is not available. Did you require it?"
    end
  end

  def self.start
      if Coverage.running?
        warn "[minidust] Coverage already started — skipping"
      else
        Coverage.start(methods: true, lines: true)
      end
  end

  def self.report
    result = Coverage.result
    config = load_config

    puts "\n== Minidust Coverage Report =="

    result.each do |file, coverage_data|
      # Skip files from the gem itself
      next if file.include?("gems/minidust")
      
      # Get relative path from project root
      relative_path = file.start_with?(ROOT_DIR) ? file.sub("#{ROOT_DIR}/", "") : file
      
      # Only show files from the project
      next unless file.start_with?(ROOT_DIR)
      
      # Check against configuration
      included = config['include_paths'].any? { |path| relative_path.start_with?(path) }
      excluded = config['exclude_paths'].any? { |path| relative_path.start_with?(path) }
      
      next unless included && !excluded

      lines_coverage = coverage_data[:lines]
      methods_coverage = coverage_data[:methods]

      # Report line coverage
      coverage_reporter = CoverageReporter.new(lines_coverage)
      coverage_reporter.report(file)

      # Report unused methods
      unused_methods_reporter = UnusedMethodsReporter.new(methods_coverage)
      unused_methods_reporter.report
    end
  end
end
