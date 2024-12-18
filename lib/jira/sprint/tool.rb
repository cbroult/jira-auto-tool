# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "date"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"
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

      class RequestBuilder
        attr_reader :jira_client

        def initialize(jira_client)
          @jira_client = jira_client
        end

        def run
          # jira_client.send(http_verb, request_args)
        end

        def build_request_args(request_url, payload)
          [
            request_url,
            payload.to_json,
            { "Content-Type" => "application/json" }
          ]
        end

        protected

        def http_verb
          raise NotImplementedError, "Subclasses must implement this method"
        end

        def expected_response
          raise NotImplementedError, "Subclasses must implement this method"
        end
      end

      class SprintCreator < RequestBuilder
        def initialize(jira_client)
          super
        end

        def http_verb
          post
        end

        def expected_response
          201
        end
      end

      def create_future_sprint(name, start, length_in_days, goal)
        sprint_creator = SprintCreator.new(jira_client)
        sprint_creator.run

        start_date = Time.parse(start)
        end_date = start_date + length_in_days.days

        response = jira_client.post(
          *build_request_args(
            "/rest/agile/1.0/sprint",
            build_create_future_sprint_payload(name, end_date, start_date, goal)
          )
        )

        if response.code.to_i == sprint_creator.expected_response
          log.info { "Sprint created successfully: #{response.body}" }
        else
          error_message = "Error creating sprint: #{response.code} - #{response.body}"
          log.error { error_message }
          raise error_message
        end
      end

      def build_create_future_sprint_payload(name, end_date, start_date, goal)
        {
          originBoardId: board.id,
          name: name,
          startDate: start_date.utc.iso8601,
          endDate: end_date.utc.iso8601,
          goal: goal
        }
      end

      class SprintStateUpdater < RequestBuilder
        def initialize(jira_client, sprint:, new_state:)
          super(jira_client)

          response = jira_client.put(*build_request_args("/rest/agile/1.0/sprint/#{sprint.id}",
                                                         build_update_sprint_state_payload(new_state, sprint)))

          if response.code.to_i == expected_response
            log.debug { "Sprint state updated successfully: #{response.body}" }
          else
            error_message = "Error updating sprint state: #{response.code} - #{response.body}"
            log.error { error_message }
            raise error_message
          end
        end

        ATTRIBUTES_TO_INCLUDE_FOR_STATE_UPDATE = %i[
          id
          self
          name
          startDate
          endDate
          originBoardId
        ].freeze

        def build_update_sprint_state_payload(new_state, sprint)
          attributes = sprint.attrs.symbolize_keys

          ATTRIBUTES_TO_INCLUDE_FOR_STATE_UPDATE.each_with_object({}) do |key, result|
            result[key] = attributes[key]
          end
            .merge({ state: new_state })
        end

        def http_verb
          :put
        end

        def expected_response
          200
        end
      end

      def update_sprint_state(sprint:, new_state:)
        SprintStateUpdater.new(jira_client, sprint: sprint, new_state: new_state)
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
