# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      RSpec.describe Sprint do
        context "when using its attributes" do
          let(:jira_client) { instance_double(JIRA::Client) }

          let(:jira_sprint) do
            # rubocop:disable RSpec/VerifiedDoubles
            double(JIRA::Resource::Sprint, name: "ART_Team_24.4.5",
                                           startDate: "2024-12-27 13:00 UTC", endDate: "2024-12-31 13:00 UTC",
                                           state: "future", originalBoardId: 16,
                                           client: jira_client)
            # rubocop:enable RSpec/VerifiedDoubles
          end

          let(:sprint) do
            described_class.new(jira_sprint, 128)
          end

          describe "#jira_client" do
            it { expect(sprint.jira_client).to eq(jira_client) }
          end

          describe "#name" do
            it { expect(sprint.name).to eq("ART_Team_24.4.5") }
          end

          describe "#length_in_days" do
            it { expect(sprint.length_in_days).to eq(4) }
          end

          describe "#start_date" do
            it { expect(sprint.start_date).to eq(Time.parse("2024-12-27 13:00 UTC").utc) }
          end

          describe "#end_date" do
            it { expect(sprint.end_date).to eq(Time.parse("2024-12-31 13:00 UTC").utc) }
          end

          describe "#state" do
            it { expect(sprint.state).to eq("future") }
          end

          describe "#board_id" do
            it { expect(sprint.board_id).to eq(128) }
          end
        end

        describe "#==" do
          def new_sprint_named(name)
            described_class.new(double(JIRA::Resource::Sprint, name: name), 256) # rubocop:disable RSpec/VerifiedDoubles
          end

          let(:shared_sprint_name) { "a shared sprint name" }

          let(:a_sprint) { new_sprint_named(shared_sprint_name) }
          let(:another_sprint_with_same_name) { new_sprint_named(shared_sprint_name) }
          let(:another_sprint_with_different_name) { new_sprint_named("different sprint name") }

          it "raise an error if the sprints are not of the same type" do
            expect { a_sprint == "not a sprint object" }
              .to raise_error(TypeError, "can't compare Jira::Auto::Tool::Sprint with String")
          end

          it do
            expect(a_sprint).to eq another_sprint_with_same_name
          end

          it do
            expect(a_sprint).not_to eq another_sprint_with_different_name
          end
        end
      end
    end
  end
end
