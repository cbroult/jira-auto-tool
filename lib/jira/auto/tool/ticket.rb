# frozen_string_literal: true

require "jira/auto/tool"
require_relative "helpers/environment_based_value"

module Jira
  module Auto
    class Tool
      class Ticket
        include Helpers::EnvironmentBasedValue

        attr_reader :tool, :jira_ticket

        def initialize(tool, jira_ticket, implementation_team = nil, expected_start_date = nil)
          @tool = tool
          @jira_ticket = jira_ticket
          @implementation_team = implementation_team
          @expected_start_date = expected_start_date
        end

        def key
          jira_ticket.key
        end

        def sprint=(sprint)
          @sprint = sprint

          jira_ticket.save!({ "fields" => { tool.jira_sprint_field.id => sprint.id } })
        end

        def sprint
          jira_ticket.fields.fetch(tool.jira_sprint_field.id)
        end

        def jira_client
          tool.jira_client
        end

        def jira_sprint_field
          tool.jira_sprint_field
        end

        def expected_start_date
          @expected_start_date || jira_field_value(expected_start_date_field.id)
        end

        IMPLEMENTATION_TEAM_VALUE_ATTRIBUTES = %w[value name].freeze

        def implementation_team
          @implementation_team ||=
            begin
              attributes = implementation_team_attributes

              IMPLEMENTATION_TEAM_VALUE_ATTRIBUTES.any? { |attr| attributes.key?(attr) } or
                raise "Implementation team #{IMPLEMENTATION_TEAM_VALUE_ATTRIBUTES.join(" and ")} " \
                      "attributes not found in #{attributes}!"

              attributes.values_at(*IMPLEMENTATION_TEAM_VALUE_ATTRIBUTES).compact.first
            end
        end

        def implementation_team_attributes
          jira_field_value(implementation_team_field.id)
        end

        def implementation_team_field
          tool.implementation_team_field
        end

        def expected_start_date_field
          tool.expected_start_date_field
        end

        def summary
          jira_ticket.summary
        end

        def jira_field_value(field_id = caller_locations(1, 1).first.base_label)
          log.debug { "jira_field_value(#{field_id})" }

          field = jira_ticket.fields.fetch(field_id) do |id|
            raise "#{id}: value not found in #{jira_ticket.fields}"
          end

          log.debug { "jira_field_value(#{field_id}), field: #{field}" }

          field
        end
      end
    end
  end
end
