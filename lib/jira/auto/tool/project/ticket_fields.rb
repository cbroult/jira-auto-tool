# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class Project
        class TicketFields
          attr_reader :tool, :project

          def initialize(tool, project)
            @tool = tool
            @project = project
          end

          def list
            table = Terminal::Table.new(
              title: "Project #{project.key} Ticket Fields",
              headings: table_row_header,
              rows: table_rows
            )

            puts table
          end

          def table_row_header
            ["Ticket Type", "Field Key", "Field Name", "Field Type", "Allowed Values"]
          end

          def table_rows
            rows = []

            each_issue_type_field do |issue_type_name, field|
              rows << [issue_type_name, field["key"], field["name"], field["schema"]["type"], allowed_values(field)]
            end

            rows.sort
          end

          def each_issue_type_field
            tool.jira_client.Createmeta.all({ projectKeys: project.key, "expand" => "projects.issuetypes.fields" })
                .each do |createmeta|
                  createmeta.attrs["issuetypes"].each do |issue_type|
                    issue_type_name = issue_type["name"]
                    issue_type["fields"].each_value do |field|
                      yield(issue_type_name, field)
                    end
                  end
            end
          end

          private

          def allowed_values(field)
            field_allowed_values = field["allowedValues"]

            if field_allowed_values
              field_allowed_values.collect do |allowed_value|
                value = allowed_value["value"] || allowed_value["name"]

                "#{value} (#{allowed_value["id"]})"
              end
            else
              "n/a"
            end
          end
        end
      end
    end
  end
end
