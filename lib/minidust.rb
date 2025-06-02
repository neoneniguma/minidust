require "coverage"
require "byebug"
require "minitest"   

require_relative "minidust/cli"

module Minidust
    COLORS = {
    red:    "\e[31m",
    green:  "\e[32m",
    yellow: "\e[33m",
    blue:   "\e[34m",
    reset:  "\e[0m"
  }

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
        Coverage.start
      end
  end

  # Use Dir.pwd to get the current project directory
  ROOT_DIR = Dir.pwd

  def self.report
    result = Coverage.result

    puts "\n== Minidust Coverage Report =="

    result.each do |file, coverage|
      # Skip files from the gem itself
      next if file.include?("gems/minidust")
      
      # Get relative path from project root
      relative_path = file.start_with?(ROOT_DIR) ? file.sub("#{ROOT_DIR}/", "") : file
      
      # Only show files from the project
      next unless file.start_with?(ROOT_DIR)

      # Only show files in lib/ directory
      next unless relative_path.start_with?("lib/")

      total = coverage.compact.size
      covered = coverage.compact.count { |c| c && c > 0 }
      percent = ((covered.to_f / total) * 100).round(2)

      color =
        if percent >= 90
          COLORS[:green]
        elsif percent >= 70
          COLORS[:yellow]
        else
          COLORS[:red]
        end


      puts "#{color}#{file}: #{percent.round(2)}% (#{covered}/#{total})#{COLORS[:reset]}"
    end
  end
end
