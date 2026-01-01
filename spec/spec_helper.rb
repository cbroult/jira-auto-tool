# frozen_string_literal: true

require "simplecov"

DISABLE_COVERAGE = ENV["DISABLE_COVERAGE"] == "true"

SimpleCov.start do
  unless DISABLE_COVERAGE
    minimum_coverage 90
    minimum_coverage_by_file 80
  end
end

require "jira/auto/tool"

RSpec.configure do |config|
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.max_formatted_output_length = nil
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include(Module.new do
    def jira_resource_double(*)
      # rubocop:disable RSpec/VerifiedDoubles
      double(*)
      # rubocop:enable RSpec/VerifiedDoubles
    end
  end)
end
