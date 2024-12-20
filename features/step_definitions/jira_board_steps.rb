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
