# frozen_string_literal: true

And(/^tickets on the board have an expected date field named "([^"]*)"$/) do |date_field_name|
  @date_field = @jira_auto_tool.expected_start_date_field(date_field_name)

  expect(@date_field).not_to be_nil
end

And(/^tickets on the board have a team field named "([^"]*)" with exactly those values:$/) do
  |team_field_name, field_values|

  expected_field_values = field_values.hashes.values.flatten

  @team_field = @jira_auto_tool.implementation_team_field(team_field_name)

  expect(@team_field.values).to eq(expected_field_values)
end

Given(/^the following tickets exist:$/) do |_table|
  # table is a table.hashes.keys # => [:summary, :team, :expected_start]
  pending
end

Then(/^the tickets should have the following attributes:$/) do |_table|
  # table is a table.hashes.keys # => [:summary, :team, :expected_start, :sprint]
  pending
end
