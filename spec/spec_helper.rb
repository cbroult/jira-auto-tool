# frozen_string_literal: true

require "jira/auto/tool"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.max_formatted_output_length = nil
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include(Module.new do
    def jira_resource_double(*args)
      # rubocop:disable RSpec/VerifiedDoubles
      double(*args)
      # rubocop:enable RSpec/VerifiedDoubles
    end
  end)
end
