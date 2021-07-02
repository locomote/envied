require "bundler/setup"
require "envied"

RSpec.configure do |config|
  # colorize output on CI
  config.tty = true

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random

  config.before do
    ENVied::Coercer.custom_types.clear
  end
end
