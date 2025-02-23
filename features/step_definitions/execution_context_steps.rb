# frozen_string_literal: true

Given("the current date time is {string}") do |current_date_time|
  set_environment_variable("JAT_CURRENT_DATE_TIME", current_date_time)
end

Given(/^the following environment variables are set:$/) do |table|
  table.hashes.each do |env_var|
    name = env_var.fetch("name")
    value = env_var.fetch("value")
    @jira_auto_tool.send("#{name.downcase}=", value)
    set_environment_variable(name, value)
  end
end

BUFFER_TIME_IN_SECONDS = 10
Then(/^successfully running `(.*)` takes between (.*) and (.*) seconds$/) do |command_line, minimal_time, maximal_time|
  start_time = Time.now

  run_command_and_stop(command_line, fail_on_error: true, timeout: maximal_time.to_i + BUFFER_TIME_IN_SECONDS)

  end_time = Time.now

  expect(end_time - start_time).to be_between(minimal_time.to_i, maximal_time.to_i)
end

Given(/^I wait for over an hour$/) do
  in_over_an_hour = (Time.now + 1.hour + 2.minute).to_s

  log.debug { "Waiting until #{in_over_an_hour}" }

  set_environment_variable("JAT_CURRENT_DATE_TIME", in_over_an_hour)
end
