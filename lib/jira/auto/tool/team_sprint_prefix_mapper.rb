# frozen_string_literal: true

require "terminal-table"

module Jira
  module Auto
    class Tool
      class TeamSprintPrefixMapper
        class NoMatchingTeamError < StandardError; end

        class NoMatchingSprintPrefixError < StandardError; end

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
              [team, team_sprint_prefix_mappings.fetch(team, "!!__no matching sprint prefix__!!")]
            end
          )

          puts table
        end

        def fetch_for(team_name)
          team_sprint_prefix_mappings[team_name]
        end

        def fetch_for!(team_name)
          fetch_for(team_name) or
            raise NoMatchingSprintPrefixError,
                  no_matching_sprint_prefix_for_team_message(team_name)
        end

        def team_sprint_prefix_mappings
          @team_sprint_prefix_mappings ||=
            sprint_prefixes.collect(&:name).each_with_object({}) do |prefix_name, mappings|
              found_team = map_prefix_name_to_team_name(prefix_name)
              mappings[prefix_name] = found_team if found_team
            end.invert
        end

        def map_prefix_name_to_team_name(prefix_name)
          sub_team_in_prefix = prefix_name.split(Sprint::Name::SPRINT_PREFIX_SEPARATOR).last

          teams.find { |team| team.end_with?(sub_team_in_prefix) }
        end

        def no_matching_sprint_prefix_for_team_message(team_name)
          "No matching sprint prefix for team '#{team_name}' in #{team_sprint_prefix_mappings.inspect}"
        end
      end
    end
  end
end
