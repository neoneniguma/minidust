# encoding: utf-8
require "coverage"
require "byebug"
require "minitest"   
require "yaml"

require_relative "minidust/cli"

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

      total = lines_coverage.compact.size
      covered = lines_coverage.compact.count { |c| c && c > 0 }
      percent = ((covered.to_f / total) * 100).round(2)

      color =
        if percent >= 90
          COLORS[:green]
        elsif percent >= 70
          COLORS[:yellow]
        else
          COLORS[:red]
        end

      color_key = percent >= 90 ? :green : percent >= 70 ? :yellow : :red
      puts "#{color}#{EMOJIS[color_key]} #{file}: #{percent.round(2)}% (#{covered}/#{total})#{COLORS[:reset]}"
      
      # Report unused methods
      if methods_coverage && methods_coverage.any?
        unused_methods = methods_coverage.select { |method, calls| calls.zero? }
        if unused_methods.any?
          puts "#{COLORS[:yellow]}  ⚠️  Unused Methods:#{COLORS[:reset]}"
          unused_methods.each do |method_data, _|
            klass, method_name, start_line, _, _, _ = method_data
            # Format the class and method name
            method_str = if klass == Object
              "#{method_name}"
            else
              "#{klass}##{method_name}"
            end
            puts "    • #{method_str} (defined on line #{start_line})"
          end
        end
      end
    end
  end
end
