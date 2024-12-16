# frozen_string_literal: true

module Jira
  module Sprint
    class Tool
      class SprintController
        class Options
          def self.add(sprint_controller, parser)
            parser.on("--sprint-add-one", "Create a follow up sprint for each of the existing sprint prefixes") do
              sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix
            end
          end
        end
      end
    end
  end
end
