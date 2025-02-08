# frozen_string_literal: true

require "active_support/core_ext/object/blank"

module Jira
  module Auto
    class Tool
      class RequestBuilder
        class SprintCreator < RequestBuilder
          def self.create_sprint(tool, original_board_id, attributes)
            log.debug { "create_sprint(#{attributes.inspect})" }

            creation_response = new(tool.jira_client, original_board_id, attributes).run

            created_sprint = Sprint.new(tool,
                                        tool.jira_client.Sprint.find(JSON.parse(creation_response.body).fetch("id")))

            log.debug { "created_sprint: #{created_sprint.id}" }

            created_sprint
          end

          protected

          attr_reader :origin_board_id, :attributes

          def initialize(jira_client, origin_board_id, attributes)
            super(jira_client)

            @origin_board_id = origin_board_id
            @attributes = attributes
          end

          def request_payload
            payload = { originBoardId: origin_board_id, name: attributes.fetch(:name) }

            payload[:startDate] = Sprint.date_for_save(start_date) if start_date
            payload[:endDate] = Sprint.date_for_save(end_date) if end_date

            payload
          end

          def start_date
            @start_date ||= extract_date(attributes[:start_date])
          end

          def end_date
            @end_date ||=
              begin
                date = extract_date(attributes[:end_date])

                if date
                  length = attributes[:length_in_days]

                  unless length.blank?
                    raise ArgumentError,
                          "Should not provide both :end_date (#{date.inspect}) and :length_in_days (#{length})!"
                  end

                  date
                elsif start_date && length_in_days
                  start_date + length_in_days.days
                end
              end
          end

          def length_in_days
            @length_in_days ||=
              begin
                raise ArgumentError, "Should provide :start_date in order to use :length_in_days!" unless start_date

                length = attributes[:length_in_days]

                length.blank? ? nil : Integer(length)
              end
          end

          def http_verb
            :post
          end

          def expected_response
            201
          end

          private

          def extract_date(date)
            case date
            when Time
              date
            else
              date.blank? ? nil : Time.parse(date)
            end
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
