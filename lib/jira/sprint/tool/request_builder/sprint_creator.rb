# frozen_string_literal: true

module Jira
  module Sprint
    class Tool
      class RequestBuilder
        class SprintCreator < RequestBuilder
          attr_reader :board, :name, :start, :length_in_days

          def initialize(jira_client, board, name, start, length_in_days)
            super(jira_client)

            @board = board
            @name = name
            @start = start
            @length_in_days = length_in_days
          end

          def request_payload
            {
              originBoardId: board.id,
              name: name,
              startDate: start_date.utc.iso8601,
              endDate: end_date.utc.iso8601
            }
          end

          def http_verb
            :post
          end

          def expected_response
            201
          end

          private

          def end_date
            start_date + length_in_days.days
          end

          def start_date
            Time.parse(start)
          end

          def request_url
            "/rest/agile/1.0/sprint"
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
