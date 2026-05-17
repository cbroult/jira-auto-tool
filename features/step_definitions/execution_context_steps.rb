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

Given(/^I wait for over a day$/) do
  in_over_a_day = (Time.now + 1.day + 2.minute).to_s

  log.debug { "Waiting until #{in_over_a_day}" }

  set_environment_variable("JAT_CURRENT_DATE_TIME", in_over_a_day)
end
