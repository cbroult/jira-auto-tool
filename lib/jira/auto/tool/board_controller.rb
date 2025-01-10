# frozen_string_literal: true

require "jira/auto/tool/board"

module Jira
  module Auto
    class Tool
      class BoardController
        attr_reader :jira_client, :tool

        def initialize(tool)
          @tool = tool
          @jira_client = tool.jira_client
        end

        def list_boards
          table = Terminal::Table.new(
            title: "Boards",
            headings: ["Project Key", "Name", "Board UI URL"],
            rows: boards.collect { |board| [board.project_key, board.name, board.ui_url] }
          )

          puts table
        end

        def boards
          boards_to_filter = unfiltered_boards

          boards_to_filter =
            if tool.jira_board_name_regex_defined?
              board_name_regex = Regexp.new(tool.jira_board_name_regex)

              boards_to_filter.find_all { |board| board.name =~ board_name_regex }
            else
              boards_to_filter
            end

          return boards_to_filter unless tool.jira_project_key_defined?

          boards_to_filter.find_all { |board| board.project_key == tool.jira_project_key }
        end

        def unfiltered_boards
          jira_client.Board.all.collect { |board| Board.new(tool, board) }
        end
      end
    end
  end
end
