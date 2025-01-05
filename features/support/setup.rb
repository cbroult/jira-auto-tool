# frozen_string_literal: true

require "aruba/cucumber"

require "rspec"

RSpec.configure do |config|
  # Enable `expect` syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.max_formatted_output_length = nil
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
