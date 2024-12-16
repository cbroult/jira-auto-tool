# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "jira-ruby"
require_relative "tool/version"
require_relative "tool/sprint_controller"
require_relative "tool/sprint_generator"
require_relative "tool/setup_logging"

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

      private

      def fetch_corresponding_environment_variable
        caller_method_name = caller_locations(1, 1).first.label

        ENV.fetch(caller_method_name.upcase) { |name| raise KeyError, "Missing #{name} environment variable!" }
      end
    end
  end
end
