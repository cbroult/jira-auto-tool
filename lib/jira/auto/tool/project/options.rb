# frozen_string_literal: true

require "jira/auto/tool/project"

module Jira
  module Auto
    class Tool
      class Project
        class Options
          def self.add(tool, parser)
            parser.on
            parser.on("Project")
            parser.on("--project-field-list",
                      "Display the fields pertaining to the ticket types of a project") do
              tool.project.list_ticket_fields
            end
          end
        end
      end
    end
  end
end
