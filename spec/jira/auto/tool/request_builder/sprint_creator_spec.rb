# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/request_builder/sprint_state_updater"

module Jira
  module Auto
    class Tool
      class RequestBuilder
        RSpec.describe SprintCreator do
          let(:sprint_creator_instance) do
            described_class.new(jira_client, 32, "a_name", "2024-12-19 13:16 UTC", 14)
          end

          let(:jira_client) { instance_spy(JIRA::Client, options: { context_path: :a_context_path }).as_null_object }

          it { expect(sprint_creator_instance.send(:request_path)).to eq("/rest/agile/1.0/sprint") }

          it { expect(sprint_creator_instance.send(:http_verb)).to eq(:post) }

          it { expect(sprint_creator_instance.send(:expected_response)).to eq(201) }

          it do
            expect(sprint_creator_instance.send(:request_payload))
              .to eq({
                       name: "a_name",
                       startDate: "2024-12-19T13:16:00Z",
                       endDate: "2025-01-02T13:16:00Z",
                       originBoardId: 32
                     })
          end

          describe ".create_sprint" do
            let(:actual_response) do
              instance_double(Net::HTTPResponse, code: "201", body: { "id" => 512 }.to_json)
            end

            let(:actual_sprints) do
              [
                instance_spy(JIRA::Resource::Sprint, id: 256),
                instance_spy(JIRA::Resource::Sprint, id: 512)
              ]
            end

            let(:jira_board) do
              instance_spy(JIRA::Resource::Board).as_null_object
            end

            it "returns the object corresponding to the created sprint" do
              allow(jira_client).to receive_messages(send: actual_response)
              allow(jira_client).to receive_messages(Sprint: actual_sprints)
              allow(actual_sprints).to receive(:find).with(512).and_return(actual_sprints.last)

              expect(described_class.create_sprint(jira_client, 32, "a_name",
                                                   "2024-12-19 13:16 UTC",
                                                   14))
                .to be_a(Sprint)
            end
          end
        end
      end
    end
  end
end
