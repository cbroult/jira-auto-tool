# frozen_string_literal: true

require_relative "request_builder/sprint_creator"
require_relative "request_builder/sprint_state_updater"

module Jira
  module Auto
    class Tool
      class RequestBuilder
        attr_reader :jira_client

        def initialize(jira_client)
          @jira_client = jira_client
        end

        def run
          response = send_request

          if response.code.to_i == expected_response
            log.debug { "#{success_message_prefix}: #{response.body}" }
          else
            error_message = "#{error_message_prefix}: #{response.code} - #{response.body}"
            log.error { error_message }
            raise error_message
          end

          response
        end

        protected

        def error_message_prefix
          raise NotImplementedError, "Subclasses must implement this method"
        end

        def expected_response
          raise NotImplementedError, "Subclasses must implement this method"
        end

        def http_verb
          raise NotImplementedError, "Subclasses must implement this method"
        end

        def request_payload
          raise NotImplementedError, "Subclasses must implement this method"
        end

        def request_path
          raise NotImplementedError, "Subclasses must implement this method"
        end

        def success_message_prefix
          raise NotImplementedError, "Subclasses must implement this method"
        end

        def request_headers
          { "Content-Type" => "application/json" }
        end

        def context_path
          jira_client.options[:context_path]
        end

        def request_path_with_context
          "#{context_path}#{request_path}"
        end

        private

        def send_request
          send_args = [http_verb, *build_request_args(request_path_with_context, request_payload)]

          log.debug { "Sending #{send_args.collect { |arg| %("#{arg}") }.join(" ")}" }

          jira_client.send(*send_args)
        end

        def build_request_args(request_url, payload)
          [
            request_url,
            payload&.to_json,
            request_headers
          ]
            .compact
        end
      end
    end
  end
end
