# frozen_string_literal: true

Given(/^a Jira Scrum board$/) do
  expect(@board).not_to be_nil
end

Given(/^the board has no sprint$/) do
  expect(@board.sprints).to be_empty
end

Given(/^the board has only closed sprints$/) do
  4.times do |sprint_index|
    @jira_auto_tool.create_sprint(name: "sprint_24.1.#{sprint_index}", state: "closed")
  end
end

DAYS_IN_A_WEEK = 7
Given(/^an unclosed (.+) sprint named (.+) starting on (.+)$/) do |sprint_length, sprint_name, start_date_time|
  length_in_days =
    case sprint_length
    when /(\d+)-week/
      Regexp.last_match(1).to_i * DAYS_IN_A_WEEK
    when /(\d+)-day/
      Regexp.last_match(1).to_i
    else
      raise "#{sprint_length} is not an expected sprint length"
    end
  @jira_auto_tool.create_sprint(name: sprint_name, start: start_date_time, length_in_days: length_in_days)
end

Then(/^a sprint named (.*) should exist$/) do |expected_name|
  unclosed_sprints = @jira_auto_tool.sprint_controller.unclosed_sprints
  expect(unclosed_sprints.collect(&:name)).to include(expected_name)
  @actual_sprint = unclosed_sprints.find { |sprint| sprint.name == expected_name }
end

And(/^it starts on (.*)$/) do |expected_start|
  expect(@actual_sprint.start_date).to eq(Time.parse(expected_start).utc)
end

And(/^it ends on (.*)$/) do |expected_end|
  expect(@actual_sprint.end_date).to eq(Time.parse(expected_end).utc)
end

Given(/^the board only has the following sprints:$/) do |_table|
  # table is a table.hashes.keys # => [:expecting-added-sprint, :name, :length, :start-date-time, :state]
  pending
end

Then(/^afterwards the board only has the following sprints:$/) do |_table|
  # table is a table.hashes.keys # => [:name, :expected-start, :expected-end, :state]
  pending
end
