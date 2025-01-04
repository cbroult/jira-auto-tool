# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "date"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"
require "jira-ruby"
require_relative "tool/project_controller"
require_relative "tool/request_builder"
require_relative "tool/setup_logging"
require_relative "tool/sprint_controller"
require_relative "tool/sprint_state_controller"
require_relative "tool/team"
require_relative "tool/team_sprint_prefix_mapper"
require_relative "tool/version"

module Jira
  module Auto
    class Tool
      class Error < StandardError; end

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

      %i[
        expected_start_date_field_name
        implementation_team_field_name
        jira_api_token
        jira_board_name
        jira_site_url
        jira_username
      ].each do |method_name|
        attr_writer method_name

        define_method(method_name) do
          instance_variable_name = "@#{method_name}"

          instance_variable_get(instance_variable_name) ||
            instance_variable_set(instance_variable_name,
                                  fetch_corresponding_environment_variable(method_name.to_s))
        end
      end

      def sprint_controller
        SprintController.new(board)
      end

      def project_ticket_fields
        # TODO: - should include project reference
        ProjectController.new(jira_client).ticket_fields
      end

      def expected_start_date_field(field_name = expected_start_date_field_name)
        field_controller.expected_start_date_field(field_name)
      end

      def implementation_team_field(field_name = implementation_team_field_name)
        field_controller.implementation_team_field(field_name)
      end

      def field_controller
        FieldController.new(jira_client)
      end

      def team_sprint_mapper
        TeamSprintPrefixMapper.new(teams, unclosed_sprint_prefixes)
      end

      def unclosed_sprints
        sprint_controller.unclosed_sprints
      end

      def unclosed_sprint_prefixes
        sprint_controller.unclosed_sprint_prefixes
      end

      def teams
        implementation_team_field.values.collect { |value| Team.new(value) }
      end

      def project
        board_project_key = board.project.symbolize_keys.fetch(:key)

        jira_client.Project.all.find { |project| project.key == board_project_key }
      end

      private

      def create_future_sprint(name, start, length_in_days)
        RequestBuilder::SprintCreator
          .new(jira_client, board.id, name, start, length_in_days)
          .run
      end

      def fetch_corresponding_environment_variable(caller_method_name = caller_locations(1, 1).first.base_label)
        environment_variable_name = caller_method_name.upcase

        log.info { "fetch_corresponding_environment_variable(#{environment_variable_name})" }

        ENV.fetch(environment_variable_name) { |name| raise KeyError, "Missing #{name} environment variable!" }
      end
    end
  end
end
