# frozen_string_literal: true

require "jira/auto/tool/until_date"

module Jira
  module Auto
    class Tool
      class TeamSprintPrefixMapper
        class Options
          def self.add(tool, parser)
            parser.on
            parser.on("Team Sprint Mapping")
            parser.on("--team-sprint-mapping-list", "--tsm-list",
                      "List the sprint and team owning their content") do
              tool.team_sprint_ticket_dispatcher.team_sprint_prefix_mapper.list_mappings
            end

            parser.on("--team-sprint-mapping-dispatch-tickets", "--tsm-dispatch",
                      "Dispatch tickets to sprint so the teams start timely working on them") do
              tool.team_sprint_ticket_dispatcher.dispatch_tickets
            end
          end
        end
      end
    end
  end
end
