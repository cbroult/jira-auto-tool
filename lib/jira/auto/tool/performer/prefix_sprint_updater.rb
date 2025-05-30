# frozen_string_literal: true

require "jira/auto/tool"

module Jira
  module Auto
    class Tool
      class Performer
        class PrefixSprintUpdater
          attr_reader :tool

          def initialize(tool)
            @tool = tool
          end

          def sprint_prefixes
            tool.unclosed_sprint_prefixes
          end

          def run
            sprint_prefixes.each do |sprint_prefix|
              @first_sprint_already_identified = false
              act_on_sprints_for_sprint_prefix(sprint_prefix)
            end
          end

          def act_on_sprints_for_sprint_prefix(sprint_prefix)
            raise NotImplementedError
          end

          def first_sprint_to_act_on?(sprint_name)
            if @first_sprint_already_identified
              false
            else
              @first_sprint_already_identified = (sprint_name =~ from_string_regex)
            end
          end
        end
      end
    end
  end
end
