module Minidust
  class CLI
    def self.start(args)
        puts("Minidust CLI starting with args: #{args.inspect}")
        if args.empty?
            puts "Usage: Minidust <test_file>"
            exit(1)
        end

        test_file = args.first

        unless File.exist?(test_file)
            puts "File notfound: #{test_file}"
            exit(1)
        end

        Minidust.enable!

        puts "Running #{test_file} with Minidust enabled..."


        load File.expand_path(test_file)
    end
  end
end