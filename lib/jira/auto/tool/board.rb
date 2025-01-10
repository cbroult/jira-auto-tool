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

        def id
          jira_board.id
        end

        def name
          jira_board.name
        end

        PROJECT_INFORMATION_NOT_AVAILABLE = "N/A"

        def project_key
          if with_project_information?
            jira_board.location.fetch("projectKey")
          else
            PROJECT_INFORMATION_NOT_AVAILABLE
          end
        end

        def with_project_information?
          jira_board.respond_to?(:location)
        end

        def url
          jira_board.url
        end

        def ui_url
          request_path =
            if with_project_information?
              "/board/#{project_key}/board/#{id}"
            else
              "/secure/RapidBoard.jspa?rapidView=#{id}"
            end

          tool.jira_url(request_path)
        end
      end
    end
  end
end
