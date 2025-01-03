# frozen_string_literal: true

require "terminal-table"

module Jira
  module Auto
    class Tool
      class TeamSprintMapper
        class NoMatchingTeamError < StandardError; end

        attr_reader :tool

        def initialize(tool)
          @tool = tool
        end

        def list_mappings
          table = Terminal::Table.new(
            title: "Team Sprint Mappings",
            headings: %w[Team Sprint],
            rows: team_sprint_mappings
          )

          puts table
        end

        def team_sprint_mappings
          sprints.collect { |sprint| [map_sprint_to_team(sprint), sprint.name] }
                 .sort
        end

        def map_sprint_to_team(sprint)
          sprint_prefix_team_mappings.fetch(sprint.name_prefix) do |_key|
            raise NoMatchingTeamError,
                  "No matching team found for sprint '#{sprint.name}' in #{sprint_prefix_team_mappings.inspect}"
          end
        end

        def sprint_prefix_team_mappings
          @sprint_prefix_team_mappings ||=
            sprint_prefixes.collect(&:name).each_with_object({}) do |prefix_name, mappings|
              mappings[prefix_name] = map_prefix_name_to_team_name(prefix_name)
            end
        end

        def map_prefix_name_to_team_name(prefix_name)
          sub_team_in_prefix = prefix_name.split(Sprint::Name::SPRINT_PREFIX_SEPARATOR).last

          teams.find { |team| team.name.end_with?(sub_team_in_prefix) }&.name or
            raise(NoMatchingTeamError,
                  "No matching team found for prefix '#{prefix_name}' in #{teams.collect(&:name).inspect}")
        end

        def sprints
          sprint_controller.unclosed_sprints
        end

        def sprint_prefixes
          sprint_controller.unclosed_sprint_prefixes
        end

        def sprint_controller
          tool.sprint_controller
        end

        def teams
          tool.teams
        end
      end
    end
  end
end
