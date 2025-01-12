# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "date"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"
require "jira-ruby"
require "jira/http_client"
require "jira/auto/tool/jira_ruby_patch/jira/http_client"
require_relative "tool/board_controller"
require_relative "tool/helpers/environment_based_value"
require_relative "tool/project_controller"
require_relative "tool/request_builder"
require_relative "tool/setup_logging"
require_relative "tool/sprint_controller"
require_relative "tool/sprint_state_controller"
require_relative "tool/team"
require_relative "tool/team_sprint_prefix_mapper"
require_relative "tool/team_sprint_ticket_dispatcher"
require_relative "tool/ticket"
require_relative "tool/version"

module Jira
  module Auto
    class Tool
      extend Helpers::EnvironmentBasedValue

      class Error < StandardError; end

      def board_name
        jira_board_name
      end

      def board
        found_board = boards.find { |a_board| a_board.name == board_name } or
          raise KeyError, "Board '#{board_name}' not found!"

        log.debug { "Jira board '#{board_name}' found: #{found_board}!" }

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
        created_sprint = create_future_sprint(name, start, length_in_days)

        log.debug { created_sprint.inspect }

        transition_sprint_state(created_sprint, desired_state: state)
      end

      def transition_sprint_state(created_sprint, desired_state:)
        SprintStateController.new(jira_client, created_sprint).transition_to(desired_state)
      end

      def jira_client
        JIRA::Client.new({
                           username: jira_username,
                           password: jira_api_token,
                           site: jira_site_url,
                           context_path: jira_context_path_when_defined_else(""),
                           auth_type: :basic,
                           http_debug: if defined?(@jira_http_debug)
                                         @jira_http_debug
                                       else
                                         jira_http_debug_defined? && jira_http_debug =~ /true|yes|1/i
                                       end
                         })
      end

      def jira_request_path(path)
        jira_client.options[:context_path] + path
      end

      def jira_base_url
        jira_client.options[:site] + jira_client.options[:context_path]
      end

      def jira_url(url)
        jira_base_url + url
      end

      %i[
        art_sprint_regex
        expected_start_date_field_name
        implementation_team_field_name
        jira_api_token
        jira_board_name
        jira_board_name_regex
        jira_context_path
        jira_http_debug
        jira_project_key
        jira_site_url
        jira_username
        jira_sprint_field_name
      ].each do |method_name|
        define_overridable_environment_based_value(method_name)
      end

      def board_controller
        BoardController.new(self)
      end

      def sprint_controller
        SprintController.new(self, board)
      end

      def project_ticket_fields
        # TODO: - should include project reference
        project_controller.ticket_fields
      end

      def project_controller
        ProjectController.new(jira_client)
      end

      def expected_start_date_field(field_name = expected_start_date_field_name)
        field_controller.expected_start_date_field(field_name)
      end

      def implementation_team_field(field_name = implementation_team_field_name)
        field_controller.implementation_team_field(field_name)
      end

      def jira_sprint_field(field_name = jira_sprint_field_name)
        field_controller.sprint_field(field_name)
      end

      def field_controller
        FieldController.new(jira_client)
      end

      def team_sprint_prefix_mapper
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

      def tickets
        jira_client.Issue.jql("project = #{project.key}").collect { |jira_ticket| Ticket.new(self, jira_ticket) }
      end

      def team_sprint_ticket_dispatcher
        TeamSprintTicketDispatcher.new(jira_client, teams, tickets, unclosed_sprint_prefixes, team_sprint_prefix_mapper)
      end

      private

      def create_future_sprint(name, start, length_in_days)
        RequestBuilder::SprintCreator
          .create_sprint(self, board.id, name, start, length_in_days)
      end
    end
  end
end
