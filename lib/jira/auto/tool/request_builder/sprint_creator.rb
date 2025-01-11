# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class RequestBuilder
        class SprintCreator < RequestBuilder
          def self.create_sprint(tool, original_board_id, name, start, length_in_days)
            log.debug { "create_sprint(name: #{name}, start: #{start}, length: #{length_in_days})" }

            creation_response = new(tool.jira_client, original_board_id, name, start, length_in_days)
                                .run

            created_sprint = Sprint.new(tool,
                                        tool.jira_client.Sprint.find(JSON.parse(creation_response.body).fetch("id")))

            log.debug { "created_sprint: #{created_sprint.id}" }

            created_sprint
          end

          protected

          attr_reader :origin_board_id, :name, :start, :length_in_days

          def initialize(jira_client, origin_board_id, name, start, length_in_days)
            super(jira_client)

            @origin_board_id = origin_board_id
            @name = name
            @start = start
            @length_in_days = length_in_days
          end

          def request_payload
            {
              originBoardId: origin_board_id,
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
            start.is_a?(Time) ? start : Time.parse(start)
          end

          def request_path
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
