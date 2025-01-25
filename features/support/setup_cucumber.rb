# frozen_string_literal: true

require "aruba/cucumber"

Aruba.configure do |config|
  config.exit_timeout = 300 # seconds

  config.activate_announcer_on_command_failure = %i[command stdout stderr]
  config.log_level = :debug
end
