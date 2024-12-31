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

        describe "#<=>" do
          def new_sprint_named(name)
            described_class.new(double(JIRA::Resource::Sprint, name: name), 256) # rubocop:disable RSpec/VerifiedDoubles
          end

          let(:abc_sprint) { new_sprint_named("abc name") }

          it { expect(abc_sprint).to eq new_sprint_named("abc name") }
          it { expect(abc_sprint).to be < new_sprint_named("xyz name") }
          it { expect(new_sprint_named("def name")).to be > abc_sprint }
        end
      end
    end
  end
end
