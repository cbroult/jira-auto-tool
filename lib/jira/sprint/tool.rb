# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "date"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"
require "jira-ruby"
require_relative "tool/request_builder"
require_relative "tool/sprint_controller"
require_relative "tool/sprint_generator"
require_relative "tool/setup_logging"
require_relative "tool/version"

module Jira
  module Sprint
    class Tool
      class Error < StandardError; end

      attr_writer :jira_board_name

      def jira_board_name
        @jira_board_name ||= fetch_corresponding_environment_variable
      end

      def board_name
        jira_board_name
      end

      def board
        boards.find { |a_board| a_board.name == board_name }
      end

      def boards
        jira_client.Board.all
      end

      def fetch_sprint(sprint_name)
        board.sprints.find { |sprint| sprint.name == sprint_name } or
          raise KeyError, "Sprint '#{sprint_name}' not found for #{board.name}!" # TODO: - test this condition
      end

      def create_sprint(name:, start: Time.now.utc.iso8601, length_in_days: 14, goal: nil, state: "future")
        create_future_sprint(name, start, length_in_days, goal)

        transition_sprint_state(name: name, desired_state: state)
      end

      def jira_client
        JIRA::Client.new({
                           username: jira_username,
                           password: jira_api_token,
                           site: jira_site_url,
                           context_path: "",
                           auth_type: :basic
                         })
      end

      def jira_api_token
        fetch_corresponding_environment_variable
      end

      def jira_site_url
        fetch_corresponding_environment_variable
      end

      def jira_username
        fetch_corresponding_environment_variable
      end

      def sprint_controller
        @sprint_controller ||= SprintController.new(board)
      end

      def sprint_generator
        @sprint_generator ||= SprintGenerator.new
      end

      module SprintState
        ACTIVE = "active"
        FUTURE = "future"
        CLOSED = "closed"
      end

      STATE_TRANSITIONS =
        {
          SprintState::FUTURE => SprintState::ACTIVE,
          SprintState::ACTIVE => SprintState::CLOSED
        }.freeze

      # TODO: - write unit tests
      # TODO - fix infinite loop in case of invalid/in-existing state
      def transition_sprint_state(name:, desired_state:)
        sprint_to_update = fetch_sprint(name)

        log.debug { "sprint_to_update = #{sprint_to_update}, desired_state = #{desired_state}" }

        current_state = sprint_to_update.state

        return if current_state == desired_state

        update_sprint_state(sprint: sprint_to_update, new_state: STATE_TRANSITIONS.fetch(current_state))

        transition_sprint_state(name: name, desired_state: desired_state)
      end

      private

      def create_future_sprint(name, start, length_in_days, goal)
        RequestBuilder::SprintCreator
          .new(jira_client, board, name, start, length_in_days, goal)
          .run
      end

      def update_sprint_state(sprint:, new_state:)
        RequestBuilder::SprintStateUpdater
          .new(jira_client, sprint: sprint, new_state: new_state)
          .run
      end

      def build_request_args(request_url, payload)
        RequestBuilder.new(jira_client).build_request_args(request_url, payload)
      end

      def fetch_corresponding_environment_variable
        caller_method_name = caller_locations(1, 1).first.label

        ENV.fetch(caller_method_name.upcase) { |name| raise KeyError, "Missing #{name} environment variable!" }
      end
    end
  end
end
