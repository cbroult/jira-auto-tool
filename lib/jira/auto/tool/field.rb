# frozen_string_literal: true

require "jira/auto/tool/request_builder/field_context_fetcher"
require "jira/auto/tool/request_builder/field_option_fetcher"

module Jira
  module Auto
    class Tool
      class Field
        include Comparable

        attr_reader :jira_client, :jira_field

        def initialize(jira_client, jira_field)
          @jira_client = jira_client
          @jira_field = jira_field
        end

        def name
          jira_field.name
        end

        def type
          jira_field.schema.fetch("type")
        end

        def id
          jira_field.id
        end

        def <=>(other)
          comparison_values(self) <=> comparison_values(other)
        end

        def values
          RequestBuilder::FieldOptionFetcher.fetch_field_options(self)
        end

        def field_context
          contexts = field_contexts

          log.warn { "field #{self} has several field contexts" } unless contexts.size == 1

          field_contexts.first # TODO: - handle several field contexts
        end

        def field_contexts
          RequestBuilder::FieldContextFetcher.fetch_field_contexts(self)
        end

        private

        def comparison_values(object)
          %i[name type id].collect { |field| object.send(field) }
        end
      end
    end
  end
end
