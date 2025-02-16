# frozen_string_literal: true

require "jira/auto/tool/performer/prefix_sprint_updater"

module Jira
  module Auto
    class Tool
      class Performer
        class PlanningIncrementSprintCreator < PrefixSprintUpdater
          attr_reader :sprint_suffix, :iteration_count

          def initialize(tool, sprint_suffix, iteration_count)
            super(tool)

            @sprint_suffix = sprint_suffix
            @iteration_count = iteration_count
          end

          def act_on_sprints_for_sprint_prefix(sprint_prefix)
            last_sprint = sprint_prefix.last_sprint
            parsed_new_name = Sprint::Name.new_with(sprint_prefix.name, sprint_suffix)

            iteration_count.times do |_iteration|
              last_sprint = create_sprint_for(last_sprint, parsed_new_name.to_s)

              sprint_prefix << last_sprint

              parsed_new_name = parsed_new_name.next_in_planning_interval
            end
          end

          def create_sprint_for(last_sprint, new_name)
            RequestBuilder::SprintCreator.create_sprint(
              tool, last_sprint.origin_board_id,
              name: new_name, start_date: last_sprint.end_date, length_in_days: last_sprint.length_in_days
            )
          end
        end
      end
    end
  end
end
