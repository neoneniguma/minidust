# Minidust

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/minidust`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minidust'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minidust

## Usage

🔧 Usage
1. Add minidust to your test helper
In your test/test_helper.rb (or wherever your Minitest setup lives), require and enable Minidust:

```ruby
require "minidust"
```

Minidust.enable!
This automatically starts coverage tracking and prints a colorized coverage report after your tests run.

2. Run your tests as usual
For example:

```bash
ruby test/hello_world_test.rb
```

You’ll see a terminal output like:

```bash
== Minidust Coverage Report ==
lib/hello_world.rb: 100.0% (6/6)
```

🔍 What it does
Tracks which lines in your app were run during each test file

Displays only the relevant files (no gem/library noise)

Outputs a colorized summary at the end of the test


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/minidust. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Minidust project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/minidust/blob/master/CODE_OF_CONDUCT.md).
