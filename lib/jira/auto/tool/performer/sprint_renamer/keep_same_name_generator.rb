# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class Performer
        class SprintRenamer
          class KeepSameNameGenerator
            def name_for(sprint_name)
              sprint_name
            end
          end
        end
      end
    end
  end
end
