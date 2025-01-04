# frozen_string_literal: true

require "terminal-table"

module Jira
  module Auto
    class Tool
      class TeamSprintPrefixMapper
        class NoMatchingTeamError < StandardError; end

        attr_reader :teams, :sprint_prefixes

        def initialize(teams, sprint_prefixes)
          @sprint_prefixes = sprint_prefixes
          @teams = teams
        end

        def list_mappings
          table = Terminal::Table.new(
            title: "Team Sprint Mappings",
            headings: ["Team", "Sprint Prefix"],
            rows: teams.collect do |team|
              [team.name, team_sprint_prefix_mappings.fetch(team.name, "!!__no matching sprint prefix__!!")]
            end
          )

          puts table
        end

        def team_sprint_mappings
          sprints.collect { |sprint| [map_sprint_to_team(sprint), sprint.name] }
                 .sort
        end

        def map_sprint_to_team(sprint)
          team_sprint_prefix_mappings.fetch(sprint.name_prefix) do |_key|
            raise NoMatchingTeamError,
                  "No matching team found for sprint '#{sprint.name}' in #{team_sprint_prefix_mappings.inspect}"
          end
        end

        def team_sprint_prefix_mappings
          @team_sprint_prefix_mappings ||=
            sprint_prefixes.collect(&:name).each_with_object({}) do |prefix_name, mappings|
              mappings[prefix_name] = map_prefix_name_to_team_name(prefix_name)
            end.invert
        end

        def map_prefix_name_to_team_name(prefix_name)
          sub_team_in_prefix = prefix_name.split(Sprint::Name::SPRINT_PREFIX_SEPARATOR).last

          teams.find { |team| team.name.end_with?(sub_team_in_prefix) }&.name or
            raise(NoMatchingTeamError,
                  "No matching team found for prefix '#{prefix_name}' in #{teams.collect(&:name).inspect}")
        end
      end
    end
  end
end
