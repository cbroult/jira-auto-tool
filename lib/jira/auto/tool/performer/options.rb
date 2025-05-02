# frozen_string_literal: true

require "optparse/time"
require "jira/auto/tool/helpers/option_parser"
require "jira/auto/tool/performer/quarterly_sprint_renamer"
require "jira/auto/tool/performer/sprint_renamer"
require "jira/auto/tool/performer/sprint_time_in_dates_aligner"
require "jira/auto/tool/performer/sprint_end_date_updater"
require "jira/auto/tool/performer/planning_increment_sprint_creator"

module Jira
  module Auto
    class Tool
      class Performer
        module Options
          def self.add(tool, parser)
            parser.section_header "Sprint"
            add_sprint_add(parser, tool)
            add_sprint_align_time_in_dates(parser, tool)
            add_quarterly_sprint_rename(parser, tool)
            add_sprint_rename(parser, tool)
            add_sprint_update_end_date(parser, tool)
          end

          def self.add_quarterly_sprint_rename(parser, tool)
            parser.on("--quarterly-sprint-rename=FROM_STRING,TO_STRING", "--qsr", Array,
                      "Rename sprints starting with FROM_STRING to TO_STRING. The following sprints in the same " \
                      "planning increment will also be renamed. ") do |from_string, to_string|
              QuarterlySprintRenamer.new(tool, from_string, to_string).run
            end
          end

          SR_SHORT_OPTION_NAME = "--sr"
          def self.add_sprint_rename(parser, tool)
            parser.on("--sprint-rename=FROM_STRING,TO_STRING", SR_SHORT_OPTION_NAME, Array,
                      "Rename sprints starting with FROM_STRING to TO_STRING. The following sprints in the same " \
                      "prefix are also all going to be renamed " \
                      "irrespective of their original planning interval " \
                      "(e.g., #{SR_SHORT_OPTION_NAME}=25.3.6,25.4.1).") do |from_string, to_string|
              SprintRenamer.new(tool, from_string, to_string).run
            end
          end

          def self.add_sprint_update_end_date(parser, tool)
            parser.on("--sprint-update-end-date=REGEX,NEW_END_DATE", "--sued", Array,
                      "Update the end of the sprint matching REGEX to NEW_END_DATE. " \
                      "The following sprints are shifted " \
                      "while keeping their original length planning increment will " \
                      "also be renamed. ") do |sprint_name_regex, new_end_date|
              SprintEndDateUpdater.new(tool, sprint_name_regex, new_end_date).run
            end
          end

          SATID_SHORT_OPTION_NAME = "--satid"
          def self.add_sprint_align_time_in_dates(parser, tool)
            parser.on("--sprint-align-time-in-dates=TIME", SATID_SHORT_OPTION_NAME, Time,
                      "Update the start and end dates of sprints to all have the specified time " \
                      "(e.g., #{SATID_SHORT_OPTION_NAME}=\"14:15 UTC\").") do |time|
              SprintTimeInDatesAligner.new(tool, time).run
            end
          end

          SA_SHORT_OPTION_NAME = "--sa"
          def self.add_sprint_add(parser, tool)
            parser.on("--sprint-add=YY.PI.START,COUNT", SA_SHORT_OPTION_NAME, Array,
                      "Add COUNT sprints for each sprint prefix/team sprints using " \
                      "the specified YY.PI.START (e.g., #{SA_SHORT_OPTION_NAME}=25.3.1) and " \
                      "the existing sprints as templates.") do |sprint_suffix, iteration_count|
              PlanningIncrementSprintCreator.new(tool, sprint_suffix, Integer(iteration_count)).run
            end
          end
        end
      end
    end
  end
end
