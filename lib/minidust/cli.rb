require 'byebug'

module Minidust
  class CLI
    def self.start(args)
        if args.empty?
            puts "Usage: minidust <test_file>"
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

          pid = Process.fork do
            require absolute_path
            puts "Running #{test_file} with Minidust enabled..."
            # Minitest.run
          end
        
          Process.wait(pid)
        end

        # Minitest.run
    end
  end
end