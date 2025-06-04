module Minidust
  class UnusedMethodsReporter
    def initialize(methods_coverage)
      @methods_coverage = methods_coverage
    end

    def report
      return unless @methods_coverage && @methods_coverage.any?
      
      unused_methods = @methods_coverage.select { |method, calls| calls.zero? }
      return if unused_methods.empty?

      puts "#{COLORS[:yellow]}  ⚠️  Unused Methods:#{COLORS[:reset]}"
      unused_methods.each do |method_data, _|
        klass, method_name, start_line, _, _, _ = method_data
        method_str = format_method_name(klass, method_name)
        puts "    • #{method_str} (defined on line #{start_line})"
      end
    end

    private

    def format_method_name(klass, method_name)
      if klass == Object
        method_name.to_s
      else
        "#{klass}##{method_name}"
      end
    end
  end
end 