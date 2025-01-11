# frozen_string_literal: true

require "jira/auto/tool"

module Jira
  module Auto
    class Tool
      class Board
        include Comparable

        attr_reader :tool, :jira_board

        def self.find_by_id(tool, id)
          new(tool, JIRA::Resource::Board.find(tool.jira_client, id))
        end

        def initialize(tool, jira_board)
          @tool = tool
          @jira_board = jira_board
        end

        def id
          jira_board.id
        end

        def <=>(other)
          id <=> other.id
        end

        def name
          jira_board.name
        end

        def self.to_table_row_field_names
          %i[name ui_url project_key]
        end

        ActiveSupport::Inflector.inflections(:en) do |inflect|
          inflect.acronym "UI" # Protects 'UI'
          inflect.acronym "URL" # Protects 'URL'
        end
        def self.to_table_row_header
          to_table_row_field_names.collect { |field| field.to_s.titleize }
        end

        def to_table_row
          self.class.to_table_row_field_names.collect { |field| send(field) }
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

        def sprint_compatible?
          jira_board.type =~ /^(scrum)$/
        end

        def url
          jira_board.url
        end

        def ui_url
          request_path =
            if with_project_information?
              "/jira/software/c/projects/#{project_key}/boards/#{id}"
            else
              "/secure/RapidBoard.jspa?rapidView=#{id}"
            end

          tool.jira_url(request_path)
        end
      end
    end
  end
end
