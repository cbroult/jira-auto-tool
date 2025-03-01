# frozen_string_literal: true

require "jira-ruby"

require "jira/auto/tool"

def ensure_the_aruba_sandbox_is_active
  ENV["HOME"] = expand_path(".")
  cd(".")

  expect(Dir.home).to eq(expand_path("."))
end

Before do
  ensure_the_aruba_sandbox_is_active

  @jira_auto_tool = Jira::Auto::Tool.new
  @jira_client = @jira_auto_tool.jira_client
  @board = @jira_auto_tool.board

  remove_existing_sprints(@jira_auto_tool)
  remove_existing_board_tickets(@jira_auto_tool)
  Jira::Auto::Tool::Board::Cache.new(@jira_auto_tool).clear
end
