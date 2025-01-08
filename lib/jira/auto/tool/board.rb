# frozen_string_literal: true

require "jira/auto/tool"

module Jira
  module Auto
    class Tool
      class Board
        attr_reader :tool, :jira_board

        def initialize(tool, jira_board)
          @tool = tool
          @jira_board = jira_board
        end

        def name
          jira_board.name
        end

        def project_key
          jira_board.project.fetch("key")
        end

        def url
          jira_board.url
        end
      end
    end
  end
end
