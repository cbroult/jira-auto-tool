# frozen_string_literal: true

require "jira/auto/tool/performer/sprint_renamer"

module Jira
  module Auto
    class Tool
      class Performer
        class SprintRenamer
          class NextNameGenerator
            attr_reader :original_name_of_first_renamed_sprint, :name_of_first_renamed_sprint

            def initialize(original_name_of_first_renamed_sprint, name_of_first_renamed_sprint)
              @original_name_of_first_renamed_sprint = Sprint::Name.parse(original_name_of_first_renamed_sprint)
              @name_of_first_renamed_sprint = Sprint::Name.parse(name_of_first_renamed_sprint)
            end

            def name_for(_sprint_name)
              next_name_in_planning_interval
            end

            def new_name_of_sprint_next_to_first_renamed_sprint
              @new_name_of_sprint_next_to_first_renamed_sprint ||=
                name_of_first_renamed_sprint.next_in_planning_interval
            end

            def next_name_in_planning_interval
              @next_name_in_planning_interval ||= new_name_of_sprint_next_to_first_renamed_sprint

              next_name = @next_name_in_planning_interval.to_s

              @next_name_in_planning_interval = @next_name_in_planning_interval.next_in_planning_interval

              next_name
            end

            def pulling_sprint_into_previous_planning_interval?
              (name_of_first_renamed_sprint.planning_interval <=>
                original_name_of_first_renamed_sprint.planning_interval)
                .negative?
            end
          end
        end
      end
    end
  end
end
