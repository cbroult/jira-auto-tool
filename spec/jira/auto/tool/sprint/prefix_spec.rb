# frozen_string_literal: true

require "jira/auto/tool/sprint/prefix"
require "jira/auto/tool/until_date"

module Jira
  module Auto
    class Tool
      class Sprint
        RSpec.describe Prefix do
          def new_prefix(name, sprints = [])
            described_class.new(name, sprints)
          end

          describe "#name" do
            it "returns the name of the prefix" do
              expect(new_prefix("ART_Team").name).to eq("ART_Team")
            end
          end

          describe "#sprints" do
            it "is empty by default" do
              expect(described_class.new("a_prefix").sprints).to be_empty
            end

            it "can be specified explicitly at creation" do
              expect(new_prefix("ART_Another-Team", %w[sprint_1 sprint_2]).sprints)
                .to eq(%w[sprint_1 sprint_2])
            end

            it "accepts new sprints" do
              prefix = new_prefix("ART_Team")
              prefix << :one_sprint
              prefix << :another_sprint

              expect(prefix.sprints).to eq(%i[another_sprint one_sprint])
            end

            context "when looking at the sprint order" do
              let(:prefix) { new_prefix("ART_Team", %i[sprint_comes_2nd sprint_comes_1st]) }

              it "has sorted sprints" do
                expect(prefix.sprints).to eq(%i[sprint_comes_1st sprint_comes_2nd])
              end

              it "stays sorted when new sprints are added" do
                prefix << :before_2nd_sprint
                prefix << :before_1st_sprint

                expect(prefix.sprints).to eq(%i[before_1st_sprint before_2nd_sprint sprint_comes_1st sprint_comes_2nd])
              end
            end
          end

          describe "#to_table_row" do
            let(:prefix) { new_prefix("Food_Supply", []) }

            let(:last_sprint) { instance_double(Sprint) }

            before { allow(prefix).to receive_messages(last_sprint: last_sprint) }

            it do
              allow(last_sprint)
                .to receive_messages(to_table_row:
                                       ["Food_Supply_24.4.5", 4, "2024-12-27 13:00 UTC", "2024-12-31 13:00 UTC",
                                        "Food Supply Team Board", :url_to_suppply_team_board, "FOOD"])

              expect(prefix.to_table_row)
                .to eq(["Food_Supply", "Food_Supply_24.4.5", 4, "2024-12-27 13:00 UTC", "2024-12-31 13:00 UTC",
                        "Food Supply Team Board", :url_to_suppply_team_board, "FOOD"])
            end

            it "can exclude the board information" do
              allow(last_sprint)
                .to receive(:to_table_row)
                .with(without_board_information: true)
                .and_return(["Food_Supply_24.4.5", 4, "2024-12-27 13:00 UTC", "2024-12-31 13:00 UTC"])

              expect(prefix.to_table_row(without_board_information: true))
                .to eq(["Food_Supply", "Food_Supply_24.4.5", 4, "2024-12-27 13:00 UTC", "2024-12-31 13:00 UTC"])
            end
          end

          describe ".to_table_row_header" do
            it do
              allow(Sprint)
                .to receive_messages(to_table_row_header: ["Name", "Length In Days", "Start Date", "End Date",
                                                           "Board Name", "Board UI URL", "Board Project Key"])

              expect(described_class.to_table_row_header)
                .to eq(["Sprint Prefix", "Last Sprint Name", "Length In Days", "Start Date", "End Date",
                        "Board Name", "Board UI URL", "Board Project Key"])
            end

            it "can exclude the board information" do
              allow(Sprint)
                .to receive(:to_table_row_header).with(without_board_information: true)
                                                 .and_return(["Name", "Length In Days", "Start Date", "End Date"])

              expect(described_class.to_table_row_header(without_board_information: true))
                .to eq(["Sprint Prefix", "Last Sprint Name", "Length In Days", "Start Date", "End Date"])
            end
          end

          describe "#<=>" do
            let(:art_team_prefix) { new_prefix("ART_Team", %w[sprint_1 sprint_2]) }

            it { expect(art_team_prefix).to eq(new_prefix("ART_Team", %w[sprint_1 sprint_2])) }
            it { expect(art_team_prefix).to be > new_prefix("ART_Team", %w[sprint_1]) }
            it { expect(art_team_prefix).to be > new_prefix("ART_Team", %w[p1 p2]) }
            it { expect(art_team_prefix).to be < new_prefix("ART_Team", %w[x1]) }
            it { expect(art_team_prefix).to be < new_prefix("GreaterART_Team", []) }
            it { expect(art_team_prefix).to be > new_prefix("AA_Team", []) }
          end

          describe "#add_sprint_following_last_one" do
            context "when unclosed sprint are found" do
              let(:actual_sprints) do
                [
                  "1st sprint",
                  "last sprint",
                  "2nd sprint"
                ]
              end

              let(:prefix) { described_class.new("sprint", actual_sprints) }
              let(:newly_added_sprint) { instance_double(Sprint, name: "sprint following last sprint") }

              it "add a sprint for the sprint prefixes having at least one unclosed sprint" do
                allow(NextSprintCreator)
                  .to receive(:create_sprint_following).with("last sprint").and_return(newly_added_sprint)
                allow(prefix).to receive_messages(:<< => nil)

                prefix.add_sprint_following_last_one

                expect(prefix).to have_received(:<<).with(newly_added_sprint)
              end
            end
          end

          describe "#add_sprints_until" do
            let(:until_date) { UntilDate.new("2024-05-15") }
            let(:prefix) { described_class.new("name_prefix") }

            it "adds no sprint if date is already covered" do
              allow(prefix).to receive_messages(covered?: true, add_sprint_following_last_one: nil)

              prefix.add_sprints_until(until_date)

              expect(prefix).not_to have_received(:add_sprint_following_last_one)
            end

            it "adds sprints until date is covered" do
              allow(prefix).to receive(:covered?).and_return(false, false, true)
              allow(prefix).to receive_messages(add_sprint_following_last_one: nil)

              prefix.add_sprints_until(until_date)

              expect(prefix).to have_received(:add_sprint_following_last_one).exactly(:twice)
            end
          end

          describe "#covered?" do
            let(:last_sprint) do
              instance_double(Sprint,
                              start_date: Time.parse("2024-05-01 11:00 UTC"),
                              end_date: Time.parse("2024-05-14 11:00 UTC"))
            end

            let(:prefix) { described_class.new("name_prefix") }

            before { allow(prefix).to receive_messages(last_sprint: last_sprint) }

            it "handles date anterior to last sprint" do
              expect(prefix_has_covered?("2024-04-30 11:00 UTC")).to be true
            end

            it "handles date included in the last sprint" do
              expect(prefix_has_covered?("2024-05-01 11:00 UTC")).to be true
            end

            it "handles time past to the last sprint end time on the same day" do
              expect(prefix_has_covered?("2024-05-14 12:00 UTC")).to be false
            end

            it "handles date past to the last sprint day" do
              expect(prefix_has_covered?("2024-05-15 11:00 UTC")).to be false
            end

            def prefix_has_covered?(date_string)
              prefix.covered?(UntilDate.new(date_string))
            end
          end

          describe "#last_sprint" do
            it "returns the last sprint as per the sprint default sort criteria" do
              prefix = new_prefix("ART_Team", %w[sprint_2 xx_last_sprint sprint_1 another_sprint1])

              expect(prefix.last_sprint).to eq("xx_last_sprint")
            end
          end
        end
      end
    end
  end
end
