# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "date"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"
require "jira-ruby"

require_relative "tool/config"
require_relative "tool/board_controller"
require_relative "tool/environment_loader"
require_relative "tool/helpers/environment_based_value"
require_relative "tool/project"
require_relative "tool/redis_rate_limited_jira_client"
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
    # rubocop:disable Metrics/ClassLength
    class Tool
      extend Helpers::EnvironmentBasedValue

      class Error < StandardError; end

      attr_reader :environment

      def initialize
        @environment = EnvironmentLoader.new(self)
      end

      def config
        @config ||= Config.new(self)
      end

      def home_dir
        File.expand_path(File.join("..", "..", ".."), __dir__)
      end

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
        board_controller.boards
      end

      def fetch_sprint(sprint_name)
        sprint_controller.sprints.find { |sprint| sprint.name == sprint_name } or
          raise KeyError, "Sprint '#{sprint_name}' not found for #{board.name}!" # TODO: - test this condition
      end

      ATTRIBUTES_TO_IGNORE_FOR_SPRINT_CREATION = %i[state].freeze

      def create_sprint(attributes)
        attributes_for_sprint_creation = attributes.except(*ATTRIBUTES_TO_IGNORE_FOR_SPRINT_CREATION)

        created_sprint = create_future_sprint(attributes_for_sprint_creation)

        log.debug { created_sprint.inspect }

        transition_sprint_state(created_sprint, desired_state: attributes.fetch(:state))
      end

      def transition_sprint_state(created_sprint, desired_state:)
        SprintStateController.new(jira_client, created_sprint).transition_to(desired_state)
      end

      def jira_client
        RedisRateLimitedJiraClient.new(jira_client_options,
                                       rate_interval_in_seconds:
                                    jat_rate_interval_in_seconds_when_defined_else(
                                      RedisRateLimitedJiraClient::NO_RATE_INTERVAL_IN_SECONDS
                                    ).to_i,
                                       rate_limit:
                                    jat_rate_limit_in_seconds_when_defined_else(
                                      RedisRateLimitedJiraClient::NO_RATE_LIMIT_IN_SECONDS
                                    ).to_i)
      end

      def jira_client_options
        {
          username: jira_username,
          password: jira_api_token,
          site: jira_site_url,
          context_path: jira_context_path_when_defined_else(""),
          auth_type: :basic,
          http_debug: jira_http_debug?
        }
      end

      def jira_http_debug?
        value = if config.key?(:jira_http_debug)
                  config[:jira_http_debug]
                else
                  jira_http_debug_defined? && jira_http_debug
                end

        result = case value
                 when String
                   value =~ /^(true|yes|1)$/i
                 else
                   value
                 end

        log.debug { "jira_http_debug? = #{result} (jira_http_debug = #{value}, config = #{config.inspect})" }

        result
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
        jat_rate_limit_in_seconds
        jat_rate_interval_in_seconds
        jat_tickets_for_team_sprint_ticket_dispatcher_jql
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
        @board_controller ||= BoardController.new(self)
      end

      def sprint_controller
        @sprint_controller ||= SprintController.new(self, board)
      end

      def project_ticket_fields
        project.ticket_fields
      end

      def project
        @project ||= Project.find(self, jira_project_key)
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
        @field_controller ||= FieldController.new(jira_client)
      end

      def unclosed_sprints
        sprint_controller.unclosed_sprints
      end

      def unclosed_sprint_prefixes
        sprint_controller.unclosed_sprint_prefixes
      end

      def teams
        implementation_team_field.values.collect { |value| Team.new(value) }.collect(&:name)
      end

      def tickets(jql = "project = #{project.key}")
        jira_client.Issue.jql(jql).collect { |jira_ticket| Ticket.new(self, jira_ticket) }
      rescue StandardError => e
        raise <<~EOEM
          Error fetching project tickets: Something went wrong:
          __________ Please check your Jira configuration and your query ______
          jql = #{jql}
          #{e.class}: #{e.message}
        EOEM
      end

      def team_sprint_ticket_dispatcher
        TeamSprintTicketDispatcher.new(jira_client,
                                       tickets(jat_tickets_for_team_sprint_ticket_dispatcher_jql),
                                       unclosed_sprint_prefixes)
      end

      private

      def create_future_sprint(attributes)
        RequestBuilder::SprintCreator
          .create_sprint(self, board.id, attributes)
      end
    end

    # rubocop:enable Metrics/ClassLength
  end
end
