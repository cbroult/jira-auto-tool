# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "date"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"
require "jira-ruby"
require_relative "tool/request_builder"
require_relative "tool/sprint_controller"
require_relative "tool/sprint_state_controller"
require_relative "tool/setup_logging"
require_relative "tool/version"

module Jira
  module Auto
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
        found_board = boards.find { |a_board| a_board.name == board_name } or
          raise KeyError, "Board '#{board_name}' not found!"

        log.info { "Jira board '#{board_name}' found: #{found_board}!" }

        found_board
      end

      def boards
        jira_client.Board.all
      end

      def fetch_sprint(sprint_name)
        sprint_controller.sprints.find { |sprint| sprint.name == sprint_name } or
          raise KeyError, "Sprint '#{sprint_name}' not found for #{board.name}!" # TODO: - test this condition
      end

      def create_sprint(name:, start: Time.now.utc.iso8601, length_in_days: 14, state: "future")
        create_future_sprint(name, start, length_in_days)

        transition_sprint_state(name: name, desired_state: state)
      end

      def transition_sprint_state(name:, desired_state:)
        SprintStateController.new(jira_client, fetch_sprint(name)).transition_to(desired_state)
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
        SprintController.new(board)
      end

      private

      def create_future_sprint(name, start, length_in_days)
        RequestBuilder::SprintCreator
          .new(jira_client, board.id, name, start, length_in_days)
          .run
      end

      def fetch_corresponding_environment_variable
        caller_method_name = caller_locations(1, 1).first.base_label

        ENV.fetch(caller_method_name.upcase) { |name| raise KeyError, "Missing #{name} environment variable!" }
      end
    end
  end
end
