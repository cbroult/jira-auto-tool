# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class EnvironmentLoader
        module Options
          def self.add(tool, parser)
            parser.section_header "Environment"

            parser.on("--env-list", "List the environment_loader variables used by the tool") do
              tool.environment.list
            end

            parser.on("--env-create-file", "Create the environment configuration file") { tool.environment.create_file }
          end
        end
      end
    end
  end
end
