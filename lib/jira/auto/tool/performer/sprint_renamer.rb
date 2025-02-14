# frozen_string_literal: true

require_relative "prefix_sprint_updater"

module Jira
  module Auto
    class Tool
      class Performer
        class SprintRenamer < PrefixSprintUpdater
          require_relative "sprint_renamer/keep_same_name_generator"
          require_relative "sprint_renamer/next_name_generator"

          attr_reader :from_string_regex, :to_string

          def initialize(tool, from_string, to_string)
            super(tool)
            @from_string_regex = Regexp.new(Regexp.escape(from_string))
            @to_string = to_string
          end

          def act_on_sprints_for_sprint_prefix(sprint_prefix)
            prefix_sprints = sprint_prefix.sprints

            new_sprint_names = calculate_sprint_new_names(prefix_sprints.collect(&:name))

            prefix_sprints.zip(new_sprint_names).each do |sprint, new_sprint_name|
              sprint.rename_to(new_sprint_name)
            end
          end

          def calculate_sprint_new_names(sprint_names)
            name_generator = KeepSameNameGenerator.new

            sprint_names.collect do |sprint_name|
              if first_sprint_to_act_on?(sprint_name)
                sprint_new_name = sprint_name.sub(from_string_regex, to_string)

                name_generator = NextNameGenerator.new(sprint_name, sprint_new_name)

                sprint_new_name
              else
                name_generator.name_for(sprint_name)
              end
            end
          end
        end
      end
    end
  end
end
