# frozen_string_literal: true

require "jira-ruby"

require "jira/auto/tool"

Before do
  @jira_auto_tool = Jira::Auto::Tool.new
  @jira_client = @jira_auto_tool.jira_client
  @board = @jira_auto_tool.board

  remove_existing_sprints(@board)
end
