require 'byebug'

module Minidust
  class CLI
    def self.start(args)
        puts("Minidust CLI starting with args: #{args.inspect}")
        if args.empty?
            puts "Usage: Minidust <test_file>"
            exit(1)
        end

        Minidust.enable!

        args.each do |test_file|
          absolute_path = File.expand_path(test_file)

          unless File.exist?(absolute_path)
            puts "File notfound: #{test_file}"
            exit(1)
          end

          # byebug

          require absolute_path
          puts "Running #{test_file} with Minidust enabled..."
        end

        Minitest.run
    end
  end
end