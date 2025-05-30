# frozen_string_literal: true

require "jira/auto/tool/sprint/name"

module Jira
  module Auto
    class Tool
      class Sprint
        RSpec.describe Name do
          describe ".parse" do
            let(:parsed_name) { described_class.parse("ART_Team_24.4.5") }

            it { expect(parsed_name.prefix).to eq("ART_Team") }
            it { expect(parsed_name.year).to eq(24) }
            it { expect(parsed_name.quarter).to eq(4) }
            it { expect(parsed_name.index_in_quarter).to eq(5) }
            it { expect(parsed_name.planning_interval).to eq([24, 4]) }

            it "raise an error if the sprint name is not according to convention" do
              expect { described_class.parse("name ignoring naming convention") }
                .to raise_error(Name::NameConventionError,
                                "'name ignoring naming convention': " \
                                "sprint name not matching #{Name::SPRINT_NAME_REGEX}!")
            end
          end

          describe "#next_in_planning_interval" do
            let(:parsed_name) { described_class.parse("ART_Team_25.2.1") }

            it do
              expect(parsed_name.next_in_planning_interval)
                .to eq(described_class.new("ART_Team", 25, 2, 2))
            end
          end

          # rubocop:disable RSpec/PredicateMatcher
          describe ".respects_naming_convention?" do
            it "returns true if the sprint name is according to convention" do
              expect(described_class.respects_naming_convention?("ART_Team_24.4.5"))
                .to be_truthy
            end

            it "returns false if the sprint name is not according to convention" do
              expect(described_class.respects_naming_convention?("name ignoring naming convention"))
                .to be_falsey
            end
          end
          # rubocop:enable RSpec/PredicateMatcher

          describe ".build" do
            it "builds the expected name" do
              expect(described_class.build("ART_Team", 25, 2, 3)).to eq("ART_Team_25.2.3")
            end
          end

          describe "#new_with" do
            it "builds the expected name" do
              expect(described_class.new_with("ART_Team", "25.3.4"))
                .to eq(described_class.new("ART_Team", 25, 3, 4))
            end

            it "fails if the sprint name is not according to convention" do
              expect { described_class.new_with("ART_Team", "MALFORMED_SUFFIX") }
                .to raise_error(
                  Name::NameConventionError,
                  "suffix not following convention 'MALFORMED_SUFFIX': " \
                  "resulting sprint name 'ART_Team_MALFORMED_SUFFIX' not matching #{Name::SPRINT_NAME_REGEX}!"
                )
            end
          end

          describe "#<=>" do
            let(:parsed_name) { described_class.parse("ART_Team_24.4.5") }

            it { expect(parsed_name).to be > described_class.parse("ART_Team_24.4.1") }
            it { expect(parsed_name).to eq described_class.parse("ART_Team_24.4.05") }
            it { expect(parsed_name).to be < described_class.parse("ART_Team_24.4.10") }

            context "when comparing to a sprint name not according to convention" do
              it { expect(parsed_name).to be > "1st sprint" }
              it { expect(parsed_name).to be < "name ignoring naming convention" }
            end
          end

          describe "#comparison_values" do
            let(:parsed_name) { described_class.parse("ART_Team_24.4.5") }

            it { expect(parsed_name.send(:comparison_values, parsed_name)).to eq(["ART_Team", 24, 4, 5]) }

            context "when sprint name not according to convention" do
              it {
                expect(parsed_name.send(:comparison_values,
                                        "name not following conventions")).to eq(["name not following conventions"])
              }
            end
          end
        end
      end
    end
  end
end
