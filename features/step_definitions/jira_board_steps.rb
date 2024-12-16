# frozen_string_literal: true

Given(/^a Jira Scrum board$/) do
  expect(@board).not_to be_nil
end

Given(/^the board has no sprint$/) do
  remove_existing_sprints(@board)
end
