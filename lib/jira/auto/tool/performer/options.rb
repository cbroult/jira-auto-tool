# frozen_string_literal: true

require "optparse/time"
require "jira/auto/tool/performer/sprint_renamer"
require "jira/auto/tool/performer/sprint_time_in_dates_aligner"

module Jira
  module Auto
    class Tool
      class Performer
        module Options
          def self.add(tool, parser)
            parser.on("--sprint-align-time-in-dates=TIME", "--satid", Time,
                      "Update the start and end dates of sprints to all have the specified time.") do |time|
              SprintTimeInDatesAligner.new(tool, time).run
            end

            parser.on("--sprint-rename=FROM_STRING,TO_STRING", "--sr", Array,
                      "Rename sprints starting with FROM_STRING to TO_STRING. The following sprints in the same " \
                      "planning increment will also be renamed. ") do |from_string, to_string|
              SprintRenamer.new(tool, from_string, to_string).run
            end
          end
        end
      end
    end
  end
end
