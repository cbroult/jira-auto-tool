# frozen_string_literal: true

require "jira/auto/tool/until_date"

module Jira
  module Auto
    class Tool
      class TeamSprintMapper
        class Options
          def self.add(_tool, parser)
            parser.on("--team-sprint-mapping-list", "--tsm-list",
                      "List the sprint and team owning their content") do
              log.warn { "PENDING implementation tool.team_sprint_mapper.list_mappings" }
            end

            parser.on("--team-sprint-mapping-dispatch-tickets", "--tsm-dispatch",
                      "Dispatch tickets to sprint so the teams start timely working on them") do
              log.warn { "PENDING implementation tool.team_sprint_mapper.distpatch_tickets" }
            end
          end
        end
      end
    end
  end
end
