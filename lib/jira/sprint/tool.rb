# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "date"
require "active_support/core_ext/numeric/time"
require "active_support/core_ext/date/calculations"
require "jira-ruby"
require "pp"
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

      module SprintState
        ACTIVE = "active"
        FUTURE = "future"
        CLOSED = "closed"
      end

      def transition_sprint_state(name:, desired_state:)
        sprint_to_update = fetch_sprint(name)

        log.debug { "sprint_to_update = #{sprint_to_update}, desired_state = #{desired_state}" }

        new_state =
          case sprint_to_update.state
          when desired_state
            return
          when SprintState::FUTURE
            SprintState::ACTIVE
          when SprintState::ACTIVE
            SprintState::CLOSED
          else
            raise "unexpected sprint state = #{sprint_to_update.state}. Was trying to transition to #{desired_state}."
          end

        update_sprint_state(sprint: sprint_to_update, new_state: new_state)
        transition_sprint_state(name: name, desired_state: desired_state)
      end

      def fetch_sprint(sprint_name)
        board.sprints.find { |sprint| sprint.name == sprint_name } or
          raise KeyError, "Sprint '#{sprint_name}' not found for #{board.name}!" # TODO: - test this condition
      end

      def create_sprint(name:, start: Time.now.utc.iso8601, length_in_days: 14, goal: nil, state: "future")
        create_future_sprint(goal, length_in_days, name, start)

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

      private

      def create_future_sprint(goal, length_in_days, name, start)
        start_date = Time.parse(start)
        end_date = start_date + length_in_days.days

        response = jira_client.post(
          "/rest/agile/1.0/sprint",
          {
            originBoardId: board.id,
            name: name,
            startDate: start_date.utc.iso8601,
            endDate: end_date.utc.iso8601,
            goal: goal
          }.to_json,
          { "Content-Type" => "application/json" }
        )

        if response.code.to_i == 201
          log.info { "Sprint created successfully: #{response.body}" }
        else
          error_message = "Error creating sprint: #{response.code} - #{response.body}"
          log.error { error_message }
          raise error_message
        end
      rescue JIRA::HTTPError => e
        puts "HTTP error occurred: #{e.response.code} - #{e.response.body}"
      rescue StandardError => e
        puts "An error occurred: #{e.message}"
      end

      ATTRIBUTES_TO_INCLUDE = %i[
        id
        self
        state
        name
        startDate
        endDate
        originBoardId
        goal
      ]

      def update_sprint_state(sprint:, new_state:)
        attributes = sprint.attrs.symbolize_keys

        payload = ATTRIBUTES_TO_INCLUDE.each_with_object({}) do |key, result|
          result[key] = attributes[key]
        end
                    .merge({ state: new_state, goal: "unspecified goal" })

        put_args = [
          "/rest/agile/1.0/sprint/#{sprint.id}",
          payload.to_json,
          { "Content-Type" => "application/json" }
        ]

        log.debug do
          pp_out = PP.pp(put_args, +"")
          "sprint = #{sprint}, new_state = #{new_state},\npayload = #{payload}\n#payload_json = #{payload.to_json}" \
            "pp put_args = #{pp_out}"
        end

        response = jira_client.put(*put_args)

        if response.code.to_i == 200
          log.info { "Sprint state updated successfully: #{response.body}" }
        else
          error_message = "Error updating sprint state: #{response.code} - #{response.body}"
          log.error { error_message }
          raise error_message
        end
      rescue JIRA::HTTPError => e
        log.error { e.message }
        raise e
      end

      def fetch_corresponding_environment_variable
        caller_method_name = caller_locations(1, 1).first.label

        ENV.fetch(caller_method_name.upcase) { |name| raise KeyError, "Missing #{name} environment variable!" }
      end
    end
  end
end
