# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class RequestBuilder
        class SprintStateUpdater < RequestBuilder
          attr_reader :sprint, :new_state

          def initialize(jira_client, sprint:, new_state:)
            super(jira_client)

            @sprint = sprint
            @new_state = new_state
          end

          private

          def request_path
            "/rest/agile/1.0/sprint/#{sprint.id}"
          end

          ATTRIBUTES_TO_INCLUDE_FOR_STATE_UPDATE = %i[
            id
            self
            name
            startDate
            endDate
            originBoardId
          ].freeze

          def request_payload
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

          def error_message_prefix
            "Error updating auto state"
          end

          def success_message_prefix
            "Sprint state updated successfully"
          end
        end
      end
    end
  end
end
