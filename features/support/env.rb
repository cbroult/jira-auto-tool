# frozen_string_literal: true

module JiraSprintToolWorld
  def remove_existing_sprints(jira_auto_tool)
    jira_auto_tool.sprint_controller.jira_sprints.each(&:delete)
  end
end

World(JiraSprintToolWorld)
