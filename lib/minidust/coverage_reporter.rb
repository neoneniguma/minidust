module Minidust
  class CoverageReporter
    def initialize(lines_coverage)
      @lines_coverage = lines_coverage
    end

    def report(file)
      total = @lines_coverage.compact.size
      covered = @lines_coverage.compact.count { |c| c && c > 0 }
      percent = ((covered.to_f / total) * 100).round(2)

      color = determine_color(percent)
      color_key = determine_color_key(percent)

      puts "#{color}#{EMOJIS[color_key]} #{file}: #{percent.round(2)}% (#{covered}/#{total})#{COLORS[:reset]}"
      
      report_unused_lines(file) if percent < 100
    end

    private

    def determine_color(percent)
      if percent >= 90
        COLORS[:green]
      elsif percent >= 70
        COLORS[:yellow]
      else
        COLORS[:red]
      end
    end

    def determine_color_key(percent)
      if percent >= 90
        :green
      elsif percent >= 70
        :yellow
      else
        :red
      end
    end

    def report_unused_lines(file)
      unused_lines = []
      @lines_coverage.each_with_index do |coverage, index|
        unused_lines << (index + 1) if coverage == 0
      end

      return if unused_lines.empty?

      puts "#{COLORS[:yellow]}  ⚠️  Unused Lines:#{COLORS[:reset]}"
      unused_lines.each do |line|
        puts "    • Line #{line}"
      end
    end
  end
end 