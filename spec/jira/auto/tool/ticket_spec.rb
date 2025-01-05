# frozen_string_literal: true

require "rspec"

require "jira/auto/tool/ticket"

module Jira
  module Auto
    class Tool
      class Ticket
        # rubocop:disable RSpec/MultipleMemoizedHelpers
        RSpec.describe Ticket do
          let(:jira_client) { instance_double(JIRA::Client) }
          let(:tool) { instance_double(Tool, jira_client: jira_client) }
          let(:jira_ticket) { jira_resource_double(JIRA::Resource::Issue, client: jira_client, key: "ART-12345") }
          let(:ticket) { described_class.new(tool, jira_ticket, nil, nil) }
          let(:sprint_field) { instance_double(Field, id: "customfield_12345", name: "Sprint") }

          describe "#key" do
            it { expect(ticket.key).to eq("ART-12345") }
          end

          context "when accessing Jira field information" do
            describe "#jira_sprint_field" do
              before { allow(tool).to receive_messages(jira_sprint_field: sprint_field) }

              it { expect(ticket.jira_sprint_field).to eq(sprint_field) }
            end

            describe "#expected_start_date_field" do
              let(:expected_start_date_field) do
                instance_double(Field, id: "customfield_80044", name: "Expected Start")
              end

              before { allow(tool).to receive_messages(expected_start_date_field: expected_start_date_field) }

              it { expect(ticket.expected_start_date_field).to eq(expected_start_date_field) }
            end
          end

          context "when accessing implementation_team information" do
            let(:implementation_team_field) do
              instance_double(Field, id: "customfield_80044", name: "Implementation Team")
            end

            before { allow(tool).to receive_messages(implementation_team_field: implementation_team_field) }

            describe "#implementation_team_field" do
              it { expect(ticket.implementation_team_field).to eq(implementation_team_field) }
            end

            describe "#implementation_team" do
              let(:fields) { { "customfield_80044" => { "value" => "A16 Logistic" } } }

              before do
                allow(jira_ticket).to receive_messages(fields: fields)
                allow(ticket).to receive_messages(implementation_team_field: implementation_team_field)
              end

              it { expect(ticket.implementation_team).to eq("A16 Logistic") }
            end
          end

          describe "#sprint=" do
            let(:sprint) { instance_double(Sprint, name: "a sprint", id: 50_400) }

            it "updates the Jira ticket" do
              allow(tool).to receive_messages(jira_sprint_field: sprint_field)
              allow(jira_ticket).to receive_messages(save!: nil)

              ticket.sprint = sprint

              expect(jira_ticket).to have_received(:save!).with({ "fields" => { "customfield_12345" => 50_400 } })
            end
          end
        end
        # rubocop:enable RSpec/MultipleMemoizedHelpers
      end
    end
  end
end
