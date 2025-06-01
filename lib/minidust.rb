require "coverage"
require "byebug"

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
    Minitest.after_run { report }
  end

  def self.start
    Coverage.start
  end

   ROOT_DIR = File.expand_path("../../", __FILE__)  # your project root

  def self.report
    result = Coverage.result

    puts "\n== Minidust Coverage Report =="

    result.each do |file, coverage|
      # Get relative path from project root
      relative_path = file.start_with?(ROOT_DIR) ? file.sub("#{ROOT_DIR}/", "") : file

      # Only show files in lib/ directory, exclude 
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
