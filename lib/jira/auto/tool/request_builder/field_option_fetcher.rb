# frozen_string_literal: true

require "jira/auto/tool/request_builder/get"
require "jira/auto/tool/field_option"

module Jira
  module Auto
    class Tool
      class RequestBuilder
        class FieldOptionFetcher < Get
          def self.fetch_field_options(field)
            log.debug { "fetching field options for #{field}" }

            response = new(field.jira_client, field, field.field_context).run

            options = JSON.parse(response.body)

            field_options = options.fetch("values", []).collect do |option|
              FieldOption.new(field.jira_client, option["id"], option["value"])
            end

            log.debug { "field #{field} options fetched: #{field_options}" }

            field_options
          end

          protected

          attr_reader :field

          def initialize(jira_client, field, field_context)
            super(jira_client)
            @field = field
            @field_context = field_context
          end

          private

          def request_path
            "/rest/api/3/field/#{field.id}/context/#{@field_context.fetch(:id)}/option"
          end

          def success_message_prefix
            "Field options fetched successfully"
          end

          def error_message_prefix
            "Error fetching field options"
          end
        end
      end
    end
  end
end
