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

            it "raise an error if the sprint name is not according to convention" do
              expect { described_class.parse("name ignoring naming convention") }
                .to raise_error(Name::NameConventionError,
                                "'name ignoring naming convention': " \
                                "sprint name not matching #{Name::SPRINT_NAME_REGEX}!")
            end
          end

          describe ".build" do
            it "builds the expected name" do
              expect(described_class.build("ART_Team", 25, 2, 3)).to eq("ART_Team_25.2.3")
            end
          end

          describe "#<=>" do
            let(:parsed_name) { described_class.parse("ART_Team_24.4.5") }

            it { expect(parsed_name).to be > described_class.parse("ART_Team_24.4.1") }
            it { expect(parsed_name).to eq described_class.parse("ART_Team_24.4.05") }
            it { expect(parsed_name).to be < described_class.parse("ART_Team_24.4.10") }
          end
        end
      end
    end
  end
end
