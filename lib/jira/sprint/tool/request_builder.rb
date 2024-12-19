# frozen_string_literal: true

require_relative "request_builder/sprint_creator"
require_relative "request_builder/sprint_state_updater"

module Jira
  module Sprint
    class Tool
      class RequestBuilder
        def run
          response = send_request

          if response.code.to_i == expected_response
            log.info { "#{success_message_prefix}: #{response.body}" }
          else
            error_message = "#{error_message_prefix}: #{response.code} - #{response.body}"
            log.error { error_message }
            raise error_message
          end
        end

        attr_reader :jira_client

        def initialize(jira_client)
          @jira_client = jira_client
        end

        protected

        def http_verb
          raise NotImplementedError, "Subclasses must implement this method"
        end

        def expected_response
          raise NotImplementedError, "Subclasses must implement this method"
        end

        private

        def send_request
          jira_client.send(http_verb, *build_request_args(request_url, request_payload))
        end

        def build_request_args(request_url, payload)
          [
            request_url,
            payload.to_json,
            { "Content-Type" => "application/json" }
          ]
        end
      end
    end
  end
end
