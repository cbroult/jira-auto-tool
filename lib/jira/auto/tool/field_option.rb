# frozen_string_literal: true

require "jira/auto/tool"

module Jira
  module Auto
    class Tool
      class FieldOption
        include Comparable

        attr_reader :jira_client, :id, :value

        def initialize(jira_client, id, value)
          @jira_client = jira_client
          @id = id
          @value = value
        end

        def to_s
          "FieldOption(id: #{id}, value: '#{value}')"
        end

        def <=>(other)
          comparison_values(self) <=> comparison_values(other)
        end

        private

        def comparison_values(object)
          %i[id value].collect { |field| object.send(field) }
        end
      end
    end
  end
end
