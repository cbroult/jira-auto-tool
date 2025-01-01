# frozen_string_literal: true

require "jira-ruby"

require "jira/auto/tool"

Before do
  @aruba_timeout_seconds = 10

  @jira_auto_tool = Jira::Auto::Tool.new
  @jira_client = @jira_auto_tool.jira_client
  @board = @jira_auto_tool.board

  remove_existing_sprints(@jira_auto_tool)
end
