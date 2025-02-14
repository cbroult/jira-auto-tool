# frozen_string_literal: true

require_relative "prefix_sprint_updater"

module Jira
  module Auto
    class Tool
      class Performer
        class SprintEndDateUpdater < PrefixSprintUpdater
          attr_reader :from_string_regex, :new_end_date

          def initialize(tool, from_string, new_end_date)
            super(tool)

            @from_string_regex = Regexp.new(Regexp.escape(from_string))
            @new_end_date = Time.parse(new_end_date)
          end

          def act_on_sprints_for_sprint_prefix(sprint_prefix)
            prefix_sprints = sprint_prefix.sprints
            update_action = :do_nothing
            new_start_date = nil

            prefix_sprints.each do |sprint|
              if first_sprint_to_act_on?(sprint.name)
                update_sprint_end_date(sprint)
                update_action = :shift_sprint_to_new_start_date
              else
                send(update_action, sprint, new_start_date)
              end

              new_start_date = sprint.end_date
            end
          end

          def do_nothing(_sprint, _new_start_date) end

          def update_sprint_end_date(sprint)
            sprint.end_date = new_end_date
            sprint.save
          end

          def shift_sprint_to_new_start_date(sprint, new_start_date)
            length_in_days = sprint.length_in_days

            sprint.start_date = new_start_date
            sprint.end_date = new_start_date + length_in_days.days

            sprint.save
          end
        end
      end
    end
  end
end
