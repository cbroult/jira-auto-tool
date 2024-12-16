# frozen_string_literal: true

require "jira-ruby"

require "jira/sprint/tool"

Before do
  @jira_sprint_tool = Jira::Sprint::Tool.new
  @jira_client = @jira_sprint_tool.jira_client
  @board = @jira_sprint_tool.board

  remove_existing_sprints(@board)
end
