# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/request_builder/sprint_state_updater"

module Jira
  module Auto
    class Tool
      class RequestBuilder
        RSpec.describe SprintCreator do
          let(:sprint_creator_instance) { described_class.new(jira_client, 32, attributes) }
          let(:attributes) { { name: "a_name", start_date: "2024-12-19 13:16 UTC", length_in_days: 14 } }

          let(:jira_client) { instance_spy(JIRA::Client, options: { context_path: :a_context_path }).as_null_object }
          let(:tool) { instance_double(Tool, jira_client: jira_client) }

          it { expect(sprint_creator_instance.send(:request_path)).to eq("/rest/agile/1.0/sprint") }

          it { expect(sprint_creator_instance.send(:http_verb)).to eq(:post) }

          it { expect(sprint_creator_instance.send(:expected_response)).to eq(201) }

          def get_date(date_string)
            Time.parse(date_string)
          end

          describe "#start_date" do
            let(:actual_start_date) { sprint_creator_instance.send(:start_date) }

            context "when no start date is provided" do
              let(:attributes) { {} }

              it { expect(actual_start_date).to be_nil }
            end

            context "when a start date is an empty string" do
              let(:attributes) { { start_date: "" } }

              it { expect(actual_start_date).to be_nil }
            end

            context "when a start date is provided" do
              let(:attributes) { { start_date: "2024-12-19 13:16 UTC" } }

              it { expect(actual_start_date).to eq(get_date("2024-12-19 13:16 UTC")) }
            end
          end

          describe "#end_date" do
            let(:actual_end_date) { sprint_creator_instance.send(:end_date) }

            context "when no end date is provided" do
              let(:attributes) { {} }

              it { expect(actual_end_date).to be_nil }
            end

            context "when end date is an empty string" do
              let(:attributes) { { end_date: "" } }

              it { expect(actual_end_date).to be_nil }
            end

            context "when no end date specified and start date with length in days are provided" do
              let(:attributes) { { start_date: "2024-12-19 13:16 UTC", length_in_days: 4 } }

              it { expect(actual_end_date).to eq(get_date("2024-12-23 13:16 UTC")) }
            end

            context "when no end date is an empty string and start date with length in days are provided" do
              let(:attributes) { { end_date: "", start_date: "2024-12-19 13:16 UTC", length_in_days: 4 } }

              it { expect(actual_end_date).to eq(get_date("2024-12-23 13:16 UTC")) }
            end

            context "when end date is provided" do
              let(:attributes) { { end_date: "2024-12-19 13:16 UTC" } }

              it { expect(actual_end_date).to eq(get_date("2024-12-19 13:16 UTC")) }
            end

            context "when end date and length in days are provided" do
              let(:attributes) { { end_date: "2024-12-19 13:16 UTC", length_in_days: 7 } }

              it do
                expect { actual_end_date }
                  .to raise_error(ArgumentError,
                                  "Should not provide both :end_date (2024-12-19 13:16:00 UTC) " \
                                  "and :length_in_days (7)!")
              end
            end
          end

          describe "#length_in_days" do
            let(:length_in_days) { sprint_creator_instance.send(:length_in_days) }

            context "when no :start_date provided" do
              let(:attributes) { { length_in_days: 5 } }

              it do
                expect { length_in_days }
                  .to raise_error(ArgumentError, "Should provide :start_date in order to use :length_in_days!")
              end
            end

            context "when :start_date provided" do
              let(:start_date_attributes) { { start_date: "2024-12-19 13:16 UTC" } }

              context "when no length in days is provided" do
                let(:attributes) { start_date_attributes.merge({}) }

                it { expect(length_in_days).to be_nil }
              end

              context "when length in days is an empty string" do
                let(:attributes) { start_date_attributes.merge({ length_in_days: "" }) }

                it { expect(length_in_days).to be_nil }
              end

              context "when length in days is a number" do
                let(:attributes) { start_date_attributes.merge({ length_in_days: 28 }) }

                it { expect(length_in_days).to eq(28) }
              end

              context "when length in days is number in a string" do
                let(:attributes) { start_date_attributes.merge({ length_in_days: "21" }) }

                it { expect(length_in_days).to eq(21) }
              end

              context "when length in days is improper integer number in a string" do
                let(:attributes) { start_date_attributes.merge({ length_in_days: "21xx" }) }

                it { expect { length_in_days }.to raise_error(ArgumentError, 'invalid value for Integer(): "21xx"') }
              end
            end
          end

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

            it "returns the object corresponding to the created sprint" do
              allow(jira_client).to receive_messages(send: actual_response)
              allow(jira_client).to receive_messages(Sprint: actual_sprints)
              allow(actual_sprints).to receive(:find).with(512).and_return(actual_sprints.last)

              expect(described_class.create_sprint(tool, 32,
                                                   { name: "a_name",
                                                     start_date: "2024-12-19 13:16 UTC",
                                                     length_in_days: 14 }))
                .to be_a(Sprint)
            end
          end
        end
      end
    end
  end
end
