require "coverage"
require "byebug"

module Minidust
  def self.start
    Coverage.start
  end

   ROOT_DIR = File.expand_path("../../", __FILE__)  # your project root

  def self.report
    byebug
    result = Coverage.result

    puts "\n== Minidust Coverage Report =="

    result.each do |file, coverage|
      # Get relative path from project root
      relative_path = file.start_with?(ROOT_DIR) ? file.sub("#{ROOT_DIR}/", "") : file

      # Only show files in lib/ directory, exclude minidust itself
      next unless relative_path.start_with?("lib/") && !relative_path.include?("minidust")

      total = coverage.compact.size
      covered = coverage.compact.count { |c| c && c > 0 }
      percent = ((covered.to_f / total) * 100).round(2)
      puts "#{relative_path}: #{percent}% (#{covered}/#{total})"
    end
  end
end
