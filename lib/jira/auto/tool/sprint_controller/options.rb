# frozen_string_literal: true

require "jira/auto/tool/until_date"

module Jira
  module Auto
    class Tool
      class SprintController
        class Options
          def self.add(tool, parser)
            add_sprint_adding_options(parser, tool)
            add_sprint_listing_options(parser, tool)
            add_sprint_prefix_listing_options(parser, tool)
          end

          def self.add_sprint_prefix_listing_options(parser, tool)
            parser.on("--sprint-prefix-list",
                      "List sprints. The output may be controlled via the ART_PREFIX_REGEX environment variable") do
              tool.sprint_controller.list_sprint_prefixes
            end

            parser.on("--sprint-prefix-list-without-board-info",
                      "List sprints without the board information. " \
                      "The output may be controlled via the ART_PREFIX_REGEX environment variable") do
              tool.sprint_controller.list_sprint_prefixes(without_board_information: true)
            end
          end

          def self.add_sprint_listing_options(parser, tool)
            parser.on("--sprint-list",
                      "List sprints. The output may be controlled via the ART_PREFIX_REGEX environment variable") do
              tool.sprint_controller.list_sprints
            end

            parser.on("--sprint-list-without-board-info",
                      "List sprints without the board information. " \
                      "The output may be controlled via the ART_PREFIX_REGEX environment variable") do
              tool.sprint_controller.list_sprints(without_board_information: true)
            end
          end

          def self.add_sprint_adding_options(parser, tool)
            parser.on("--sprint-add-one",
                      "Create a follow up sprint for each of the existing unclosed sprint prefixes") do
              tool.sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix
            end

            parser.accept(UntilDate) { |until_date_string| UntilDate.new(until_date_string) }

            parser.on("--sprint-add-until=DATE", UntilDate,
                      "Create sprints until date is included for each of the unclosed sprint prefixes") do |until_date|
              tool.sprint_controller.add_sprints_until(until_date)
            end
          end
        end
      end
    end
  end
end
