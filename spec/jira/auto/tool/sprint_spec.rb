# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      RSpec.describe Sprint do
        context "when using its attributes" do
          let(:jira_client) { instance_double(JIRA::Client) }

          let(:jira_sprint) do
            # rubocop:disable RSpec/VerifiedDoubles
            double(JIRA::Resource::Sprint,
                   id: 40_820,
                   name: "ART_Team_24.4.5",
                   startDate: "2024-12-27 13:00 UTC", endDate: "2024-12-31 13:00 UTC",
                   state: "future", originBoardId: 4096,
                   client: jira_client)
            # rubocop:enable RSpec/VerifiedDoubles
          end

          let(:sprint) do
            described_class.new(jira_sprint)
          end

          describe "#jira_client" do
            it { expect(sprint.jira_client).to eq(jira_client) }
          end

          describe "#id" do
            it { expect(sprint.id).to eq(40_820) }
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

          describe "#origin_board_id" do
            it { expect(sprint.origin_board_id).to eq(4096) }
          end
        end

        describe "#<=>" do
          def new_sprint_named(name, start_date: "2024-12-30 13:00 UTC", end_date: "2025-01-14 13:00 UTC")
            # rubocop:disable RSpec/VerifiedDoubles
            described_class.new(
              double(JIRA::Resource::Sprint, name: name, startDate: start_date, endDate: end_date,
                                             originBoardId: 2048)
            )
            # rubocop:enable RSpec/VerifiedDoubles
          end

          let(:abc_sprint) { new_sprint_named("abc name_24.4.9") }

          it { expect(abc_sprint).to eq new_sprint_named("abc name_24.4.9") }
          it { expect(abc_sprint).to be < new_sprint_named("xyz name_24.4.9") }
          it { expect(new_sprint_named("def name_24.3.9")).to be > abc_sprint }

          it { expect(new_sprint_named("foo_bar_24.4.9")).to be < new_sprint_named("foo_bar_24.4.10") }

          it do
            expect(new_sprint_named("foo_bar_24.4.9", end_date: "2025-01-14 13:00 UTC"))
              .to be < new_sprint_named("foo_bar_24.4.9", end_date: "2025-01-15 13:00 UTC")
          end
        end
      end
    end
  end
end
