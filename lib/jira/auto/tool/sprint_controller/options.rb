# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class SprintController
        class Options
          def self.add(sprint_controller, parser)
            parser.on("--sprint-add-one", "Create a follow up auto for each of the existing auto prefixes") do
              sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix
            end
          end
        end
      end
    end
  end
end
