# frozen_string_literal: true

require "jira/auto/tool/request_builder/get"
require "jira/auto/tool/field_option"

module Jira
  module Auto
    class Tool
      class RequestBuilder
        class FieldContextFetcher < Get
          def self.fetch_field_contexts(field)
            log.debug { "fetching field contexts for #{field}" }

            response = new(field.jira_client, field).run

            field_contexts =
              JSON
              .parse(response.body)
              .symbolize_keys
              .fetch(:values)
              .collect(&:symbolize_keys)

            log.debug { "field #{field} contexts fetched: #{field_contexts}" }

            field_contexts
          end

          protected

          attr_reader :field

          def initialize(jira_client, field)
            super(jira_client)
            @field = field
          end

          def request_payload
            nil
          end

          def http_verb
            :get
          end

          def expected_response
            200
          end

          def request_headers
            nil
          end

          private

          def end_date
            start_date + length_in_days.days
          end

          def start_date
            start.is_a?(Time) ? start : Time.parse(start)
          end

          def request_path
            "/rest/api/3/field/#{field.id}/context"
          end

          def success_message_prefix
            "Sprint created successfully"
          end

          def error_message_prefix
            "Error creating sprint"
          end
        end
      end
    end
  end
end
