# frozen_string_literal: true

require "jira/auto/tool/helpers/option_parser"
require "jira/auto/tool/board_controller"
require "jira/auto/tool/board/cache"

module Jira
  module Auto
    class Tool
      class BoardController
        class Options
          def self.add(tool, parser)
            parser.section_header "Board"

            parser.on("--board-name=STRING", String) do |board_name|
              tool.jira_board_name = board_name
            end

            parser.on("--board-cache-clear", "Clear the board cache so they are requested again.") do
              tool.board_controller.clear_cache
            end

            parser.on("--board-list", "List boards. The output can be controlled via the " \
                                      "#{Tool::Environment::JIRA_BOARD_NAME_REGEX} environment variable") do
              tool.board_controller.list_boards
            end
          end
        end
      end
    end
  end
end
