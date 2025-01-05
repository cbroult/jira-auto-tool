# frozen_string_literal: true

require "jira/auto/tool"
require_relative "field"

module Jira
  module Auto
    class Tool
      class FieldController
        class FieldNotFoundError < StandardError; end
        class ExpectedFieldTypeError < StandardError; end

        def initialize(jira_client)
          @jira_client = jira_client
        end

        def sprint_field(field_name)
          field_fetcher(field_name, "array")
        end

        def expected_start_date_field(field_name)
          field_fetcher(field_name, "date")
        end

        def implementation_team_field(field_name)
          field_fetcher(field_name, "option")
        end

        def ticket_fields
          @jira_client.Field.all.collect { |field| Field.new(@jira_client, field) }
        rescue StandardError => e
          raise "Error fetching project ticket fields: Something went wrong:\n#{e}"
        end

        private

        def field_fetcher(field_name, expected_type)
          field = ticket_fields.find { |f| f.name == field_name } or
            raise FieldNotFoundError, "Field '#{field_name}' not found!"

          field.type == expected_type or
            raise ExpectedFieldTypeError,
                  "Field '#{field_name}' expected to have type '#{expected_type}', but was '#{field.type}'."

          field
        end
      end
    end
  end
end
