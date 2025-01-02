# frozen_string_literal: true

require "jira/auto/tool/field_controller"

module Jira
  module Auto
    class Tool
      class ProjectController
        def initialize(jira_client)
          @jira_client = jira_client
        end

        def ticket_fields
          FieldController.new(jira_client).ticket_fields
        end

        private

        attr_reader :jira_client
      end
    end
  end
end
