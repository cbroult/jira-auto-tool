# frozen_string_literal: true

module JiraSprintToolWorld
  def log
    @log ||= Logging.logger[self]
  end

  def remove_existing_sprints(jira_auto_tool)
    sprints = jira_auto_tool.sprint_controller.sprints

    log.debug { "Removing sprints #sprints = #{sprints.size}: #{sprints.map(&:name).join(", ")}" }

    sprints.each do |sprint|
      sprint.delete
    rescue JIRA::HTTPError => e
      raise unless e.response.code == "404"

      log.warn { "Sprint #{sprint.name} not found on delete — already removed or non-deletable state" }
    end
  end

  def remove_existing_board_tickets(jira_auto_tool)
    tickets = jira_auto_tool.jira_client.Issue.jql("project = #{jira_auto_tool.board.project_key}")

    log.debug { "Removing tickets from board #{jira_auto_tool.board.name}:  #tickets = #{tickets.size}" }

    tickets.each(&:delete)
  end
end

World(JiraSprintToolWorld)
