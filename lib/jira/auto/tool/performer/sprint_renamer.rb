# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class Performer
        class SprintRenamer
          attr_reader :tool, :from_string_regex, :to_string

          def initialize(tool, from_string, to_string)
            @tool = tool
            @from_string_regex = Regexp.new(Regexp.escape(from_string))
            @to_string = to_string
          end

          def sprint_prefixes
            tool.unclosed_sprint_prefixes
          end

          def run
            sprint_prefixes.each { |sprint_prefix| rename_sprints_for_sprint_prefix(sprint_prefix) }
          end

          def rename_sprints_for_sprint_prefix(sprint_prefix)
            prefix_sprints = sprint_prefix.sprints

            new_sprint_names = calculate_sprint_new_names(prefix_sprints.collect(&:name))

            prefix_sprints.zip(new_sprint_names).each do |sprint, new_sprint_name|
              sprint.rename_to(new_sprint_name)
            end
          end

          def calculate_sprint_new_names(sprint_names)
            parsed_name_of_first_sprint_to_rename = nil
            parsed_name_of_sprint_next_to_initially_renamed_sprint = nil
            next_sprint_parsed_name = nil

            sprint_names.collect do |sprint_name|
              if sprint_name =~ from_string_regex
                parsed_name_of_first_sprint_to_rename = Sprint::Name.parse(sprint_name)
              end

              if parsed_name_of_first_sprint_to_rename &&
                 !beyond_planning_interval_of_sprint_next_to_initially_renamed_sprint(
                   sprint_name, parsed_name_of_sprint_next_to_initially_renamed_sprint
                 )

                if next_sprint_parsed_name
                  sprint_new_name = next_sprint_parsed_name.to_s

                  next_sprint_parsed_name = next_sprint_parsed_name.next_in_planning_interval

                  sprint_new_name
                else
                  sprint_new_name = sprint_name.sub(from_string_regex, to_string)

                  next_sprint_parsed_name =
                    parsed_name_of_sprint_next_to_initially_renamed_sprint =
                      initial_next_sprint_parsed_name(sprint_name, sprint_new_name)

                  sprint_new_name
                end
              else
                sprint_name
              end
            end
          end

          def beyond_planning_interval_of_sprint_next_to_initially_renamed_sprint(
            sprint_name, parsed_name_of_sprint_next_to_initially_renamed_sprint
          )
            parsed_name_of_sprint_next_to_initially_renamed_sprint &&
              parsed_name_of_sprint_next_to_initially_renamed_sprint.planning_interval !=
                Sprint::Name.parse(sprint_name).planning_interval
          end

          def calculate_sprint_new_name(sprint_name, next_sprint_parsed_name)
            if next_sprint_parsed_name
              [next_sprint_parsed_name.to_s, next_sprint_parsed_name.next_in_planning_interval]
            else
              sprint_new_name = sprint_name.sub(from_string_regex, to_string)

              [sprint_new_name, initial_next_sprint_parsed_name(sprint_name, sprint_new_name)]
            end
          end

          def initial_next_sprint_parsed_name(initial_sprint_name, initial_sprint_new_name)
            initial_sprint_parsed_name = Sprint::Name.parse(initial_sprint_name)

            initial_sprint_parsed_new_name = Sprint::Name.parse(initial_sprint_new_name)

            if pushing_sprint_to_next_planning_interval?(initial_sprint_parsed_name, initial_sprint_parsed_new_name)
              initial_sprint_parsed_new_name.next_in_planning_interval
            else
              initial_sprint_parsed_name
            end
          end

          def pushing_sprint_to_next_planning_interval?(sprint_parsed_name, sprint_parsed_new_name)
            sprint_parsed_name < sprint_parsed_new_name
          end
        end
      end
    end
  end
end
