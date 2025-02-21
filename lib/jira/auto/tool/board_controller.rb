# frozen_string_literal: true

require "jira/auto/tool/board"
require "jira/auto/tool/board/cache"

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
          return cached_boards if valid_cache?

          cache_boards(filtered_boards)
        end

        def clear_cache
          cache.clear
        end

        private

        def filtered_boards
          named_filtered_boards = apply_board_name_filter(unfiltered_boards)

          apply_project_key_filter(named_filtered_boards)
        end

        def unfiltered_boards
          @unfiltered_boards ||= request_boards
        end

        def valid_cache?
          cache.valid?
        end

        def cached_boards
          cache.boards
        end

        def cache
          @cache ||= Board::Cache.new(tool)
        end

        def request_boards
          jira_client.Board.all.collect { |board| Board.new(tool, board) }
        end

        def cache_boards(boards)
          cache.save(boards)
        end

        def apply_project_key_filter(boards_to_filter)
          return boards_to_filter unless tool.jira_project_key_defined?

          boards_to_filter.find_all do |board|
            !board.with_project_information? ||
              board.project_key == tool.jira_project_key
          end
        end

        def apply_board_name_filter(boards_to_filter)
          return boards_to_filter unless tool.jira_board_name_regex_defined?

          board_name_regex = Regexp.new(tool.jira_board_name_regex)

          boards_to_filter.find_all { |board| board.name =~ board_name_regex }
        end
      end
    end
  end
end
