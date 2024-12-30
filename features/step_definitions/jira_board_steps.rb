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
def parse_length_in_days(length_string)
  case length_string
  when /(\d+)-week/
    Regexp.last_match(1).to_i * DAYS_IN_A_WEEK
  when /(\d+)-day/
    Regexp.last_match(1).to_i
  else
    raise "#{length_string} is not an expected sprint length"
  end
end

Given(/^an unclosed (.+) sprint named (.+) starting on (.+)$/) do |sprint_length, sprint_name, start_date_time|
  @jira_auto_tool.create_sprint(name: sprint_name, start: start_date_time,
                                length_in_days: parse_length_in_days(sprint_length))
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

Given(/^the board only has the following sprints:$/) do |table|
  table.hashes.each do |sprint_hash|
    @jira_auto_tool.create_sprint(
      name: sprint_hash[:name],
      start: sprint_hash[:start],
      length_in_days: parse_length_in_days(sprint_hash[:length]),
      state: sprint_hash[:state]
    )
  end
end

Then(/^afterwards the board only has the following sprints:$/) do |table|
  expected_sprints = table.hashes.collect(&:values).collect(&:flatten)
  actual_sprints = @jira_auto_tool.sprint_controller.sprints.collect do |sprint|
    [sprint.name, sprint.start_date.utc.to_s, sprint.state]
  end

  expect(actual_sprints).to contain_exactly(*expected_sprints)
end
