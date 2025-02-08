# frozen_string_literal: true

require "jira/auto/tool"

module Jira
  module Auto
    class Tool
      class Performer
        class SprintTimeInDatesAligner
          attr_reader :tool, :sprint_time_in_dates

          def initialize(tool, sprint_time_in_dates)
            @tool = tool
            @sprint_time_in_dates =
              if sprint_time_in_dates.is_a?(String)
                Time.parse(sprint_time_in_dates)
              else
                sprint_time_in_dates
              end
          end

          def run
            update_sprint_dates_with_expected_time
          end

          def update_sprint_dates_with_expected_time
            tool.unclosed_sprints.each { |sprint| update_sprint_dates_for(sprint) }
          end

          def update_sprint_dates_for(sprint)
            return if sprint.closed? || !(sprint.start_date? || sprint.end_date?)

            sprint.start_date = date_with_expected_time(sprint.start_date) if sprint.start_date?
            sprint.end_date = date_with_expected_time(sprint.end_date) if sprint.end_date?

            sprint.save
          end

          private

          def date_with_expected_time(original_date)
            original_date = Time.parse(original_date) if original_date.is_a?(String)

            original_date.change(
              hour: sprint_time_in_dates.hour, min: sprint_time_in_dates.min, sec: sprint_time_in_dates.sec
            )
          end
        end
      end
    end
  end
end
