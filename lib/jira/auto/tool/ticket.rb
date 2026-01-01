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
        rescue StandardError => e
          message = "Failed to set sprint for ticket #{key} to #{sprint.id}! #{self}"

          log.error { message }

          raise e.class, message
        end

        def to_s
          "Ticket(#{to_s_fields.collect { |field| "#{field}: #{send(field)}" }.join(", ")})"
        end

        def to_s_fields
          %i[key summary sprint implementation_team expected_start_date]
        end

        # Compatibility helper to access Issue fields across Jira API versions
        # - jira-ruby v2: JIRA::Resource::Issue responds to #fields
        # - jira-ruby v3: fields are nested under #attrs['fields']
        def ticket_fields
          if jira_ticket.respond_to?(:fields)
            jira_ticket.fields
          else
            raise "attrs not found in #{jira_ticket}!" unless jira_ticket.respond_to?(:attrs)

            attrs = jira_ticket.attrs
            attrs["fields"] || attrs[:fields] ||
              raise("fields not found in #{attrs} from #{jira_ticket}!")
          end
        end

        def sprint
          ticket_fields.fetch(tool.jira_sprint_field.id)
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

              if attributes.nil?
                nil
              else
                IMPLEMENTATION_TEAM_VALUE_ATTRIBUTES.any? { |attr| attributes.key?(attr) } or
                  raise "Implementation team #{IMPLEMENTATION_TEAM_VALUE_ATTRIBUTES.join(" and ")} " \
                        "attributes not found in #{attributes}!"

                attributes.values_at(*IMPLEMENTATION_TEAM_VALUE_ATTRIBUTES).compact.first
              end
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

          field = ticket_fields.fetch(field_id) do |id|
            raise "#{id}: value not found in #{ticket_fields}"
          end

          log.debug { "jira_field_value(#{field_id}), field: #{field}" }

          field
        end
      end
    end
  end
end
