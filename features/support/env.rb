# frozen_string_literal: true

module JiraSprintToolWorld
  def log
    @log ||= Logging.logger[self]
  end

  def remove_existing_sprints(jira_auto_tool)
    sprints = jira_auto_tool.sprint_controller.sprints

    log.debug { "Removing sprints #sprints = #{sprints.size}: #{sprints.map(&:name).join(", ")}" }

    sprints.each { |sprint| delete_sprint(jira_auto_tool, sprint) }
  end

  def remove_existing_board_tickets(jira_auto_tool)
    tickets = jira_auto_tool.jira_client.Issue.jql("project = #{jira_auto_tool.board.project_key}",
                                                   fields: ["key"])

    log.debug { "Removing tickets from board #{jira_auto_tool.board.name}:  #tickets = #{tickets.size}" }

    tickets.each { |ticket| delete_ticket(ticket) }
  end

  private

  def delete_sprint(jira_auto_tool, sprint)
    close_active_sprint(jira_auto_tool, sprint)
    sprint.delete
  rescue JIRA::HTTPError => e
    raise unless e.response.code == "404"

    log.warn { "Sprint #{sprint.name} not found on delete — already removed or non-deletable state" }
  end

  def delete_ticket(ticket)
    ticket.delete
  rescue JIRA::HTTPError => e
    raise unless e.response.code == "404"

    log.warn { "Ticket #{ticket.key} not found on delete — already removed" }
  end

  def close_active_sprint(jira_auto_tool, sprint)
    return unless sprint.state == Jira::Auto::Tool::SprintStateController::SprintState::ACTIVE

    Jira::Auto::Tool::SprintStateController
      .new(jira_auto_tool.jira_client, sprint)
      .transition_to(Jira::Auto::Tool::SprintStateController::SprintState::CLOSED)
  rescue StandardError => e
    log.warn { "Failed to close active sprint #{sprint.name} before delete: #{e.message}" }
  end
end

World(JiraSprintToolWorld)
