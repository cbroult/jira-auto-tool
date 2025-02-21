# frozen_string_literal: true

require "time"

Given(/^a Jira Scrum board$/) do
  expect(@board).not_to be_nil
end

Given(/^the board has no sprint$/) do
  expect(@board.jira_board.sprints).to be_empty
end

Given(/^the board has only closed sprints$/) do
  4.times do |sprint_index|
    @jira_auto_tool.create_sprint(name: "sprint_24.1.#{sprint_index}", state: "closed",
                                  start_date: Time.now + sprint_index.days, length_in_days: 14)
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
  @jira_auto_tool.create_sprint({ name: sprint_name, start_date: start_date_time,
                                  length_in_days: parse_length_in_days(sprint_length), state: "future" })
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

And(/^its state is (.*)$/) do |expected_state|
  expect(@actual_sprint.state).to eq(expected_state)
end

Given(/^the board only has the following sprints:$/) do |table|
  table_value_keys = table.raw.first

  table.hashes.each do |sprint_hash|
    attributes = {}

    table_value_keys.each do |key|
      value = sprint_hash[key]

      case key.intern
      when :length
        attributes[:length_in_days] = parse_length_in_days(value)
      when :expecting_added_sprint, :comment
        next
      else
        attributes[key.intern] = value
      end
    end

    @jira_auto_tool.create_sprint(attributes)
  end
end

Then(/^afterwards the board only has the following sprints:$/) do |table|
  expected_value_keys = table.raw.first

  expected_sprints = table.hashes.collect(&:values).collect(&:flatten)

  actual_sprints = @jira_auto_tool.sprint_controller.sprints.collect do |sprint|
    expected_value_keys.collect do |key|
      unavailable_date = key =~ /date/ && !sprint.send("#{key}?")

      value = unavailable_date ? "" : sprint.send(key)

      value.is_a?(Time) ? value.utc.to_s : value
    end
  end

  expect(actual_sprints).to contain_exactly(*expected_sprints)
end

Then(/^the output contains (no )?requests that enumerate the list of boards$/) do |contains_or_not|
  contains_predicate = contains_or_not.nil? || contains_or_not.empty? ? :to : :not_to

  board_enumeration_pattern = /#{Regexp.escape("get: /rest/agile/1.0/board - []")}/
  expect(last_command_started.output).send(contains_predicate, match(board_enumeration_pattern))
end
