# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/project/ticket_fields"

module Jira
  module Auto
    class Tool
      class Project
        # rubocop:disable Metrics/ClassLength
        class TicketFields
          RSpec.describe TicketFields do
            let(:ticket_fields) { described_class.new(tool, project) }
            let(:tool) { instance_double(Tool) }
            let(:project) { instance_double(Project, key: "project_key") }

            describe "#list" do
              let(:expected_list_output) do
                <<~EOELO
                  +-------------+-----------+---------------------+------------+---------------------------------------------------+
                  |                                       Project project_key Ticket Fields                                        |
                  +-------------+-----------+---------------------+------------+---------------------------------------------------+
                  | Ticket Type | Field Key | Field Name          | Field Type | Allowed Values                                    |
                  +-------------+-----------+---------------------+------------+---------------------------------------------------+
                  | Story       | 10001     | key                 | String     | n/a                                               |
                  | Story       | 10000     | Summary             | String     | n/a                                               |
                  | Story       | 10002     | Story Points        | Number     | n/a                                               |
                  | Epic        | 10001     | Implementation Team | Set        | ["Food Platform", "Food Delivery", "Food Supply"] |
                  +-------------+-----------+---------------------+------------+---------------------------------------------------+
                EOELO
              end

              before do
                allow(ticket_fields)
                  .to receive_messages(table_rows: [
                                         ["Story", 10_001, "key", "String", "n/a"],
                                         ["Story", 10_000, "Summary", "String", "n/a"],
                                         ["Story", 10_002, "Story Points", "Number", "n/a"],
                                         ["Epic", 10_001, "Implementation Team", "Set",
                                          ["Food Platform", "Food Delivery", "Food Supply"]]
                                       ])
              end

              it do
                expect { ticket_fields.list }.to output(expected_list_output).to_stdout
              end
            end

            describe "#table_row_header" do
              it {
                expect(ticket_fields.table_row_header).to eq(["Ticket Type", "Field Key", "Field Name", "Field Type",
                                                              "Allowed Values"])
              }
            end

            describe "#table_rows" do
              let(:jira_client) { jira_resource_double(JIRA::Client) }
              let(:createmeta) { jira_resource_double(JIRA::Resource::Createmeta, all: all_createmeta) }
              let(:all_createmeta) do
                [jira_resource_double(JIRA::Resource::Createmeta, attrs:
                  { "id" => "10006",
                    "key" => "JATCIDEVLX",
                    "name" => "JAT CI/CD - Dev - Linux",
                    "issuetypes" =>
                      [{ "id" => "10005",
                         "name" => "Task",
                         "untranslatedName" => "Task",
                         "subtask" => false,
                         "fields" =>
                           { "summary" =>
                               { "schema" => { "type" => "string", "system" => "summary" },
                                 "name" => "Summary",
                                 "key" => "summary" },
                             "customfield_10081" =>
                               { "schema" =>
                                   { "type" => "date",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:datepicker",
                                     "customId" => 10_081 },
                                 "name" => "Expected Start",
                                 "key" => "customfield_10081" },
                             "customfield_10082" =>
                               { "schema" =>
                                   { "type" => "option",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:select",
                                     "customId" => 10_082 },
                                 "name" => "Implementation Team",
                                 "key" => "customfield_10082",
                                 "allowedValues" =>
                                   [{ "value" => "A16 CRM", "id" => "10044" },
                                    { "value" => "A16 E2E-Test", "id" => "10045" },
                                    { "value" => "A16 Logistic", "id" => "10048" },
                                    { "value" => "A16 Platform", "id" => "10046" },
                                    { "value" => "A16 Sys-Team", "id" => "10047" }] },
                             "customfield_10020" =>
                               { "schema" =>
                                   { "type" => "array",
                                     "items" => "json",
                                     "custom" => "com.pyxis.greenhopper.jira:gh-sprint",
                                     "customId" => 10_020 },
                                 "name" => "Sprint",
                                 "key" => "customfield_10020" },
                             "customfield_10001" =>
                               { "schema" =>
                                   { "type" => "team",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:atlassian-team",
                                     "customId" => 10_001,
                                     "configuration" =>
                                       { "com.atlassian.jira.plugin.system.customfieldtypes:atlassian-team" =>
                                           true } },
                                 "name" => "Team",
                                 "key" => "customfield_10001" } } },
                       { "id" => "10006",
                         "name" => "Sub-task",
                         "untranslatedName" => "Sub-task",
                         "subtask" => true,
                         "fields" =>
                           { "summary" =>
                               { "schema" => { "type" => "string", "system" => "summary" },
                                 "name" => "Summary",
                                 "key" => "summary" },
                             "customfield_10081" =>
                               { "schema" =>
                                   { "type" => "date",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:datepicker",
                                     "customId" => 10_081 },
                                 "name" => "Expected Start",
                                 "key" => "customfield_10081" },
                             "customfield_10082" =>
                               { "schema" =>
                                   { "type" => "option",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:select",
                                     "customId" => 10_082 },
                                 "name" => "Implementation Team",
                                 "key" => "customfield_10082",
                                 "allowedValues" =>
                                   [{ "value" => "A16 CRM", "id" => "10044" },
                                    { "value" => "A16 E2E-Test", "id" => "10045" },
                                    { "value" => "A16 Logistic", "id" => "10048" },
                                    { "value" => "A16 Platform", "id" => "10046" },
                                    { "value" => "A16 Sys-Team", "id" => "10047" }] },
                             "customfield_10020" =>
                               { "schema" =>
                                   { "type" => "array",
                                     "items" => "json",
                                     "custom" => "com.pyxis.greenhopper.jira:gh-sprint",
                                     "customId" => 10_020 },
                                 "name" => "Sprint",
                                 "key" => "customfield_10020" },
                             "customfield_10001" =>
                               { "schema" =>
                                   { "type" => "team",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:atlassian-team",
                                     "customId" => 10_001,
                                     "configuration" =>
                                       { "com.atlassian.jira.plugin.system.customfieldtypes:atlassian-team" =>
                                           true } },
                                 "name" => "Team",
                                 "key" => "customfield_10001" } } },
                       { "id" => "10003",
                         "name" => "Story",
                         "untranslatedName" => "Story",
                         "subtask" => false,
                         "fields" =>
                           { "summary" =>
                               { "schema" => { "type" => "string", "system" => "summary" },
                                 "name" => "Summary",
                                 "key" => "summary" },
                             "customfield_10081" =>
                               { "schema" =>
                                   { "type" => "date",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:datepicker",
                                     "customId" => 10_081 },
                                 "name" => "Expected Start",
                                 "key" => "customfield_10081" },
                             "customfield_10082" =>
                               { "schema" =>
                                   { "type" => "option",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:select",
                                     "customId" => 10_082 },
                                 "name" => "Implementation Team",
                                 "key" => "customfield_10082",
                                 "allowedValues" =>
                                   [{ "value" => "A16 CRM", "id" => "10044" },
                                    { "value" => "A16 E2E-Test", "id" => "10045" },
                                    { "value" => "A16 Logistic", "id" => "10048" },
                                    { "value" => "A16 Platform", "id" => "10046" },
                                    { "value" => "A16 Sys-Team", "id" => "10047" }] },
                             "customfield_10020" =>
                               { "schema" =>
                                   { "type" => "array",
                                     "items" => "json",
                                     "custom" => "com.pyxis.greenhopper.jira:gh-sprint",
                                     "customId" => 10_020 },
                                 "name" => "Sprint",
                                 "key" => "customfield_10020" },
                             "customfield_10001" =>
                               { "schema" =>
                                   { "type" => "team",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:atlassian-team",
                                     "customId" => 10_001,
                                     "configuration" =>
                                       { "com.atlassian.jira.plugin.system.customfieldtypes:atlassian-team" =>
                                           true } },
                                 "name" => "Team",
                                 "key" => "customfield_10001" } } },
                       { "id" => "10007",
                         "name" => "Bug",
                         "untranslatedName" => "Bug",
                         "subtask" => false,
                         "fields" =>
                           { "summary" =>
                               { "schema" => { "type" => "string", "system" => "summary" },
                                 "name" => "Summary",
                                 "key" => "summary" },
                             "customfield_10081" =>
                               { "schema" =>
                                   { "type" => "date",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:datepicker",
                                     "customId" => 10_081 },
                                 "name" => "Expected Start",
                                 "key" => "customfield_10081" },
                             "customfield_10082" =>
                               { "schema" =>
                                   { "type" => "option",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:select",
                                     "customId" => 10_082 },
                                 "name" => "Implementation Team",
                                 "key" => "customfield_10082",
                                 "allowedValues" =>
                                   [{ "value" => "A16 CRM", "id" => "10044" },
                                    { "value" => "A16 E2E-Test", "id" => "10045" },
                                    { "value" => "A16 Logistic", "id" => "10048" },
                                    { "value" => "A16 Platform", "id" => "10046" },
                                    { "value" => "A16 Sys-Team", "id" => "10047" }] },
                             "customfield_10020" =>
                               { "schema" =>
                                   { "type" => "array",
                                     "items" => "json",
                                     "custom" => "com.pyxis.greenhopper.jira:gh-sprint",
                                     "customId" => 10_020 },
                                 "name" => "Sprint",
                                 "key" => "customfield_10020" },
                             "customfield_10001" =>
                               { "schema" =>
                                   { "type" => "team",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:atlassian-team",
                                     "customId" => 10_001,
                                     "configuration" =>
                                       { "com.atlassian.jira.plugin.system.customfieldtypes:atlassian-team" =>
                                           true } },
                                 "name" => "Team",
                                 "key" => "customfield_10001" },
                             "environment" =>
                               { "schema" => { "type" => "string", "system" => "environment" },
                                 "name" => "Environment",
                                 "key" => "environment" } } },
                       { "id" => "10000",
                         "name" => "Epic",
                         "untranslatedName" => "Epic",
                         "subtask" => false,
                         "fields" =>
                           { "summary" =>
                               { "schema" => { "type" => "string", "system" => "summary" },
                                 "name" => "Summary",
                                 "key" => "summary" },
                             "customfield_10081" =>
                               { "schema" =>
                                   { "type" => "date",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:datepicker",
                                     "customId" => 10_081 },
                                 "name" => "Expected Start",
                                 "key" => "customfield_10081" },
                             "customfield_10082" =>
                               { "schema" =>
                                   { "type" => "option",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:select",
                                     "customId" => 10_082 },
                                 "name" => "Implementation Team",
                                 "key" => "customfield_10082",
                                 "allowedValues" =>
                                   [{ "value" => "A16 CRM", "id" => "10044" },
                                    { "value" => "A16 E2E-Test", "id" => "10045" },
                                    { "value" => "A16 Logistic", "id" => "10048" },
                                    { "value" => "A16 Platform", "id" => "10046" },
                                    { "value" => "A16 Sys-Team", "id" => "10047" }] },
                             "customfield_10020" =>
                               { "schema" =>
                                   { "type" => "array",
                                     "items" => "json",
                                     "custom" => "com.pyxis.greenhopper.jira:gh-sprint",
                                     "customId" => 10_020 },
                                 "name" => "Sprint",
                                 "key" => "customfield_10020" },
                             "customfield_10001" =>
                               { "schema" =>
                                   { "type" => "team",
                                     "custom" =>
                                       "com.atlassian.jira.plugin.system.customfieldtypes:atlassian-team",
                                     "customId" => 10_001,
                                     "configuration" =>
                                       { "com.atlassian.jira.plugin.system.customfieldtypes:atlassian-team" =>
                                           true } },
                                 "name" => "Team",
                                 "key" => "customfield_10001" } } }] })]
              end

              let(:expected_table_rows) do
                [
                  ["Bug", "customfield_10001", "Team", "team", "n/a"],
                  ["Bug", "customfield_10020", "Sprint", "array", "n/a"],
                  ["Bug", "customfield_10081", "Expected Start", "date", "n/a"],
                  ["Bug", "customfield_10082", "Implementation Team", "option",
                   ["A16 CRM (10044)",
                    "A16 E2E-Test (10045)",
                    "A16 Logistic (10048)",
                    "A16 Platform (10046)",
                    "A16 Sys-Team (10047)"]],
                  ["Bug", "environment", "Environment", "string", "n/a"],
                  ["Bug", "summary", "Summary", "string", "n/a"],
                  ["Epic", "customfield_10001", "Team", "team", "n/a"],
                  ["Epic", "customfield_10020", "Sprint", "array", "n/a"],
                  ["Epic", "customfield_10081", "Expected Start", "date", "n/a"],
                  ["Epic", "customfield_10082", "Implementation Team", "option",
                   ["A16 CRM (10044)",
                    "A16 E2E-Test (10045)",
                    "A16 Logistic (10048)",
                    "A16 Platform (10046)",
                    "A16 Sys-Team (10047)"]],
                  ["Epic", "summary", "Summary", "string", "n/a"],
                  ["Story", "customfield_10001", "Team", "team", "n/a"],
                  ["Story", "customfield_10020", "Sprint", "array", "n/a"],
                  ["Story", "customfield_10081", "Expected Start", "date", "n/a"],
                  ["Story", "customfield_10082", "Implementation Team", "option",
                   ["A16 CRM (10044)",
                    "A16 E2E-Test (10045)",
                    "A16 Logistic (10048)",
                    "A16 Platform (10046)",
                    "A16 Sys-Team (10047)"]],
                  ["Story", "summary", "Summary", "string", "n/a"],
                  ["Sub-task", "customfield_10001", "Team", "team", "n/a"],
                  ["Sub-task", "customfield_10020", "Sprint", "array", "n/a"],
                  ["Sub-task", "customfield_10081", "Expected Start", "date", "n/a"],
                  ["Sub-task", "customfield_10082", "Implementation Team", "option",
                   ["A16 CRM (10044)",
                    "A16 E2E-Test (10045)",
                    "A16 Logistic (10048)",
                    "A16 Platform (10046)",
                    "A16 Sys-Team (10047)"]],
                  ["Sub-task", "summary", "Summary", "string", "n/a"],
                  ["Task", "customfield_10001", "Team", "team", "n/a"],
                  ["Task", "customfield_10020", "Sprint", "array", "n/a"],
                  ["Task", "customfield_10081", "Expected Start", "date", "n/a"],
                  ["Task", "customfield_10082", "Implementation Team", "option",
                   ["A16 CRM (10044)",
                    "A16 E2E-Test (10045)",
                    "A16 Logistic (10048)",
                    "A16 Platform (10046)",
                    "A16 Sys-Team (10047)"]],
                  ["Task", "summary", "Summary", "string", "n/a"]
                ]
              end

              before do
                allow(tool).to receive_messages(jira_client: jira_client)
                allow(jira_client).to receive_messages(Createmeta: createmeta)
              end

              it { expect(ticket_fields.table_rows).to eq(expected_table_rows) }
            end
          end
        end
        # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
