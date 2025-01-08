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
            headings: ["Name", "Project Key", "Board URL"],
            rows: boards.collect { |board| [board.name, board.project_key, board.url] }
          )

          puts table
        end

        def boards
          jira_client.Board.all.collect { |board| Board.new(tool, board) }
        end
      end
    end
  end
end
