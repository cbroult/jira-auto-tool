# frozen_string_literal: true

require "jira/auto/tool/sprint/prefix"

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

              expect(prefix.sprints).to eq(%i[one_sprint another_sprint])
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

          describe "#last_sprint" do
            it "returns the last sprint as per the sprint default sort criteria }" do
              prefix = new_prefix("ART_Team", %w[sprint_2 xx_last_sprint sprint_1 another_sprint1])

              expect(prefix.last_sprint).to eq("xx_last_sprint")
            end
          end
        end
      end
    end
  end
end
