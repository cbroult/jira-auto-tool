# frozen_string_literal: true

require "jira/auto/tool/performer/sprint_renamer"

module Jira
  module Auto
    class Tool
      class Performer
        module Options
          def self.add(tool, parser)
            parser.on("--sprint-rename=FROM_STRING,TO_STRING", Array,
                      "Rename sprints starting with FROM_STRING to TO_STRING. The following sprints in the same " \
                      "planning increment will also be renamed. ") do |from_string, to_string|
              SprintRenamer
                .new(tool, from_string, to_string)
                .run
            end
          end
        end
      end
    end
  end
end
