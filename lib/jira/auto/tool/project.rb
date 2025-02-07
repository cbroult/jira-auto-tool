# frozen_string_literal: true

require "terminal-table"
require "jira/auto/tool/field_controller"
require "jira/auto/tool/project/ticket_fields"

module Jira
  module Auto
    class Tool
      class Project
        def self.find(tool, project_key)
          new(tool, tool.jira_client.Project.find(project_key))
        end

        def initialize(tool, jira_project)
          @tool = tool
          @jira_project = jira_project
        end

        def key
          jira_project.key
        end

        def list_ticket_fields
          ticket_fields.list
        end

        def ticket_fields
          TicketFields.new(tool, self)

          # FieldController.new(jira_client).ticket_fields
        end

        private

        attr_reader :tool, :jira_project
      end
    end
  end
end
