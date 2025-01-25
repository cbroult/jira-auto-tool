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
          get_optional_date :startDate
        end

        def end_date
          get_optional_date :endDate
        end

        UNDEFINED_DATE = Time.new(1970, 1, 1, 0, 0, 0, "UTC")

        def get_optional_date(jira_field_id)
          return UNDEFINED_DATE unless jira_sprint.respond_to?(jira_field_id)

          parse_date(jira_sprint.send(jira_field_id))
        end

        def missing_dates?
          start_date == UNDEFINED_DATE || end_date == UNDEFINED_DATE
        end

        def rename_to(new_name)
          return if new_name == name || closed?

          remove_attributes_that_causes_errors_on_save

          jira_sprint.attrs["name"] = new_name
          jira_sprint.save!
        end

        def remove_attributes_that_causes_errors_on_save
          jira_sprint.attrs.delete("rapidview_id")
        end

        def state
          @jira_sprint.state
        end

        def closed?
          state == SprintStateController::SprintState::CLOSED
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
          %i[id name length_in_days start_date end_date]
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
        rescue StandardError => e
          raise e.class, "#{e.class}: sprint #{name.inspect}: #{e.message}:\n#{inspect}"
        end

        private

        def comparison_values(object)
          comparison_fields(object).collect { |field| object.send(field) }
        end

        def comparison_fields(object)
          %i[start_date end_date] +
            if Name.respects_naming_convention?(object.name)
              [:parsed_name]
            else
              [:name]
            end
        end

        def parse_date(date)
          Time.parse(date).utc
        end
      end
    end
  end
end
