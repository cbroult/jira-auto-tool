# frozen_string_literal: true

require_relative "sprint_renamer"

module Jira
  module Auto
    class Tool
      class Performer
        class QuarterlySprintRenamer < SprintRenamer
          require_relative "quarterly_sprint_renamer/next_name_generator"

          def next_sprint_name_generator_class
            QuarterlySprintRenamer::NextNameGenerator
          end
        end
      end
    end
  end
end
