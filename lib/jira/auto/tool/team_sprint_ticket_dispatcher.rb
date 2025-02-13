# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class TeamSprintTicketDispatcher
        attr_reader :jira_client, :tickets, :sprint_prefixes

        def initialize(jira_client, tickets, sprint_prefixes)
          @jira_client = jira_client
          @tickets = tickets
          @sprint_prefixes = sprint_prefixes
        end

        def dispatch_tickets
          per_team_tickets do |team, tickets|
            log.debug { "#{team}: dispatching tickets #{tickets.collect(&:key).join(", ")}" }

            sprint_prefix_matching_team = sprint_prefix_for(team)

            if sprint_prefix_matching_team.nil?
              log.warn { team_sprint_prefix_mapper.no_matching_sprint_prefix_for_team_message(team) }
            else
              dispatch_tickets_to_prefix_sprints(sprint_prefix_matching_team, tickets)
            end
          end
        end

        def sprint_prefix_for(team)
          team_sprint_prefix_mapper.fetch_for(team)
        end

        def dispatch_tickets_to_prefix_sprints(prefix_name, tickets)
          prefix = sprint_prefixes.find { |sprint_prefix| sprint_prefix.name == prefix_name }

          tickets.each do |ticket|
            matched_sprint = match_ticket_to_prefix_sprint(prefix, ticket)

            ticket.sprint = matched_sprint if matched_sprint
          end
        end

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

        def per_team_tickets(&)
          return enum_for(:per_team_tickets) unless block_given?

          team_ticket_map = tickets.group_by(&:implementation_team)

          team_ticket_map.each(&)
        end

        def team_sprint_prefix_mapper
          TeamSprintPrefixMapper.new(teams, sprint_prefixes)
        end

        def teams
          tickets.collect(&:implementation_team).uniq.sort
        end
      end
    end
  end
end
