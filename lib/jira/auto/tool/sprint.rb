# frozen_string_literal: true

require "delegate"
require "jira-ruby"

require_relative "sprint_state_controller"

module Jira
  module Auto
    class Tool
      class Sprint < SimpleDelegator
        include Comparable

        attr_reader :jira_sprint, :tool

        def initialize(tool, jira_sprint)
          super(jira_sprint)
          @tool = tool
          @jira_sprint = jira_sprint
        end

        def id
          @jira_sprint.id
        end

        def name
          @jira_sprint.name
        end

        def length_in_days
          (end_date - start_date) / 1.day
        end

        def start_date
          parse_date(startDate)
        end

        def end_date
          parse_date(endDate)
        end

        def state
          @jira_sprint.state
        end

        def origin_board_id
          @jira_sprint.originBoardId
        end

        def index_in_quarter
          parsed_name.index_in_quarter
        end

        def board
          @board ||= Board.find_by_id(tool, origin_board_id)
        end

        def jira_client
          @jira_sprint.client
        end

        def name_prefix
          parsed_name.prefix
        end

        def parsed_name
          Name.parse(name)
        end

        def <=>(other)
          comparison_values(self) <=> comparison_values(other)
        end

        def to_s
          "name = #{name}, start_date = #{start_date}, end_date = #{end_date}, length_in_days = #{length_in_days}"
        end

        def self.to_table_row_field_names
          %i[name length_in_days start_date end_date]
        end

        def self.to_table_row_header(without_board_information: false)
          header = to_table_row_field_names.collect { |field| field.to_s.titleize }

          header.concat(Board.to_table_row_header.collect { |field| "Board #{field}" }) unless without_board_information

          header
        end

        def to_table_row(without_board_information: false)
          row = self.class.to_table_row_field_names.collect { |field| send(field) }

          row.concat(board.to_table_row) unless without_board_information

          row
        end

        private

        def comparison_values(object)
          %i[start_date end_date parsed_name].collect { |field| object.send(field) }
        end

        def parse_date(date)
          Time.parse(date).utc
        end
      end
    end
  end
end
