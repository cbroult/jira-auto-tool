# frozen_string_literal: true

require "rspec"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.max_formatted_output_length = nil
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
