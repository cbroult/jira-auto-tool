# frozen_string_literal: true

require "jira/auto/tool/next_sprint_creator"

module Jira
  module Auto
    class Tool
      RSpec.describe NextSprintCreator do
        let(:jira_client) { instance_double(JIRA::Client) }
        let(:sprint) do
          instance_double(Sprint,
                          name: "ART_Team_24.4.5",
                          start_date: Time.parse("2024-12-27 13:00:00 UTC"),
                          end_date: Time.parse("2024-12-31 13:00:00 UTC"),
                          name_prefix: "ART_Team",
                          length_in_days: 4,
                          index_in_quarter: 5,
                          state: "closed",
                          board_id: 64,
                          jira_client: jira_client)
        end

        let(:next_sprint_creator_instance) do
          described_class.new(sprint)
        end

        describe "#create_sprint_following" do
          it "requests the sprint creation with the expected attributes" do
            allow(RequestBuilder::SprintCreator).to receive(:create_sprint)

            described_class.create_sprint_following(sprint)

            expect(RequestBuilder::SprintCreator)
              .to have_received(:create_sprint)
              .with(jira_client, 64, "ART_Team_24.4.6", "2024-12-31 13:00:00 UTC", 4)
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
