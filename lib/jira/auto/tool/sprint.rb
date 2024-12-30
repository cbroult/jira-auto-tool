# frozen_string_literal: true

require "delegate"
require "jira-ruby"

require_relative "sprint_state_controller"

module Jira
  module Auto
    class Tool
      class Sprint < SimpleDelegator
        attr_reader :board_id

        def initialize(jira_sprint, board_id)
          super(jira_sprint)
          @jira_sprint = jira_sprint
          @board_id = board_id
        end

        def name
          @jira_sprint.name
        end

        def add_one_sprint
          RequestBuilder::SprintCreator.create_sprint
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

        def original_board_id
          @jira_sprint.originalBoardId
        end

        def index_in_quarter
          parsed_name.index_in_quarter
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

        def ==(other)
          raise TypeError, "can't compare #{self.class} with #{other.class}" unless other.is_a?(self.class)

          other.name == name
        end

        private

        attr_reader :jira_sprint

        def parse_date(date)
          Time.parse(date).utc
        end
      end
    end
  end
end
