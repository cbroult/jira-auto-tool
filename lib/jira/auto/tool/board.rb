# frozen_string_literal: true

require "jira/auto/tool/board/unavailable_board"

module Jira
  module Auto
    class Tool
      class Board
        include Comparable

        attr_reader :tool, :jira_board

        def self.find_by_id(tool, id)
          cached_boards[id] ||=
            begin
              new(tool, JIRA::Resource::Board.find(tool.jira_client, id))
            rescue JIRA::HTTPError => e
              if e.code.to_i == 404
                UnavailableBoard.new(tool, id)
              else
                raise e.class,
                      "#{e.class}: code = #{e.code.inspect}: #{self.class}.find_by_id(tool, #{id.inspect}): " \
                      "#{e.message}"
              end
            end
        end

        def self.cached_boards
          @cached_boards ||= {}
        end

        def initialize(tool, jira_board)
          @tool = tool
          @jira_board = jira_board
        end

        def id
          jira_board.id
        end

        def unavailable?
          instance_of?(UnavailableBoard)
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
          inflect.acronym "UI"
          inflect.acronym "URL"
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
