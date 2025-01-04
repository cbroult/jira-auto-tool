# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class TeamSprintTicketDispatcher
        attr_reader :jira_client, :teams, :tickets, :sprint_prefixes, :team_sprint_prefix_mapper

        def initialize(jira_client, teams, tickets, sprint_prefixes, team_sprint_prefix_mapper)
          @jira_client = jira_client
          @teams = teams
          @tickets = tickets
          @sprint_prefixes = sprint_prefixes
          @team_sprint_prefix_mapper = team_sprint_prefix_mapper
        end

        def dispatch_tickets
          per_team_tickets do |team, tickets|
            dispatch_tickets_to_prefix_sprints(sprint_prefix_for(team), tickets)
          end
        end

        def sprint_prefix_for(team)
          team_sprint_prefix_mapper.fetch_for(team)
        end

        def dispatch_tickets_to_prefix_sprints(prefix, tickets); end

        def match_ticket_to_prefix_sprint(prefix, ticket)
          ticket_start_time = Time.parse(ticket.expected_start_date).end_of_day

          first_sprint_when_overdue_ticket(ticket_start_time, prefix) ||
            prefix.sprints.find do |sprint|
              sprint.start_date <= ticket_start_time && sprint.end_date >= ticket_start_time
            end
        end

        def first_sprint_when_overdue_ticket(ticket_start_time, prefix)
          first_sprint = prefix.sprints.first

          ticket_start_time < first_sprint.start_date ? first_sprint : nil
        end

        def per_team_tickets
          return enum_for(:per_team_tickets) unless block_given?

          team_ticket_map = tickets.group_by(&:implementation_team)

          teams.each do |team|
            yield(team, team_ticket_map.fetch(team))
          end
        end
      end
    end
  end
end
