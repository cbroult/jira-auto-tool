# frozen_string_literal: true

require "jira/auto/tool/next_sprint_creator"

module Jira
  module Auto
    class Tool
      RSpec.describe NextSprintCreator do
        let(:jira_client) { instance_double(JIRA::Client) }
        let(:last_sprint_name) { "ART_Team_24.4.5" }
        let(:last_sprint_index_in_quarter) { 5 }
        let(:last_sprint_start) { "2024-12-27 13:00:00 UTC" }
        let(:last_sprint_end) { "2024-12-31 13:00:00 UTC" }

        def last_sprint
          instance_double(Sprint,
                          name: last_sprint_name,
                          start_date: Time.parse(last_sprint_start),
                          end_date: Time.parse(last_sprint_end),
                          name_prefix: "ART_Team",
                          length_in_days: 4,
                          index_in_quarter: last_sprint_index_in_quarter,
                          state: "closed",
                          origin_board_id: 512,
                          jira_client: jira_client)
        end

        def next_sprint_creator_instance
          described_class.new(last_sprint)
        end

        describe ".create_sprint_following" do
          RSpec.shared_examples "a next sprint creator" do |expected|
            it "requests the sprint creation with the expected attributes" do
              allow(RequestBuilder::SprintCreator).to receive(:create_sprint)

              described_class.create_sprint_following(last_sprint)

              expect(RequestBuilder::SprintCreator)
                .to have_received(:create_sprint)
                .with(jira_client, 512,
                      expected[:next_sprint_name],
                      Time.parse(expected[:next_sprint_start]).utc.to_s,
                      4)
            end
          end

          context "when next sprint is in the same quarter" do
            it_behaves_like "a next sprint creator", { next_sprint_name: "ART_Team_24.4.6",
                                                       next_sprint_start: "2024-12-31 13:00:00 UTC" }
          end

          context "when next sprint is in the coming year" do
            let(:last_sprint_start) { "2024-12-31 13:00:00 UTC" }
            let(:last_sprint_end) { "2025-01-03 13:00:00 UTC" }

            it_behaves_like "a next sprint creator",
                            { next_sprint_name: "ART_Team_25.1.1", next_sprint_start: "2025-01-03 13:00:00 UTC" }
          end

          context "when the current sprint starts locally at midnight and UTC is not yet in the new year" do
            let(:last_sprint_name) { "ART_Team_25.1.1" }
            let(:last_sprint_start) { "2025-01-01 00:00:00 +01:00" }
            let(:last_sprint_end) { "2025-01-03 00:00:00 +01:00" }
            let(:last_sprint_index_in_quarter) { 1 }

            it_behaves_like "a next sprint creator",
                            { next_sprint_name: "ART_Team_25.1.2", next_sprint_start: "2025-01-03 00:00:00 +01:00" }
          end
        end

        describe "#same_quarter?" do
          it { expect(next_sprint_creator_instance.same_quarter?).to be true }
        end

        describe "#next_sprint_start_date" do
          it { expect(next_sprint_creator_instance.next_sprint_start_date).to eq(Time.parse("2024-12-31 13:00 UTC")) }
        end

        describe "#next_sprint_length_in_days" do
          it { expect(next_sprint_creator_instance.next_sprint_length_in_days).to eq(4) }
        end
      end
    end
  end
end
