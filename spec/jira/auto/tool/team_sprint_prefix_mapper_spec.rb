# frozen_string_literal: true

require "rspec"

module Jira
  module Auto
    class Tool
      class TeamSprintPrefixMapper
        RSpec.describe TeamSprintPrefixMapper do
          let(:mapper) do
            described_class.new(teams, unclosed_sprint_prefixes)
          end

          let(:teams) { ["A16 CRM", "A16 Logistic", "A16 Platform", "A32 64 Sys-Team"] }

          let(:expected_team_sprint_prefix_mappings) do
            {
              "A16 CRM" => "ART-16_CRM",
              "A16 Platform" => "ART-16_Platform",
              "A32 64 Sys-Team" => "ART-32-64_Sys-Team"
            }
          end

          let(:unclosed_sprint_prefixes) do
            %w[ART-16_CRM ART-16_Platform ART-32-64_Sys-Team].collect do |name|
              instance_double(Sprint::Prefix, name: name)
            end
          end

          describe "#sprint_prefixes" do
            it { expect(mapper.sprint_prefixes).to eq unclosed_sprint_prefixes }
          end

          describe "#teams" do
            it { expect(mapper.teams).to eq teams }
          end

          describe "#team_sprint_prefix_mappings" do
            it { expect(mapper.team_sprint_prefix_mappings).to eq(expected_team_sprint_prefix_mappings) }
          end

          describe "#fetch_for" do
            it { expect(mapper.fetch_for("A16 CRM")).to eq "ART-16_CRM" }
            it { expect(mapper.fetch_for("A32 64 Sys-Team")).to eq "ART-32-64_Sys-Team" }

            it "raises an error if the prefix is not found" do
              expect { mapper.fetch_for("team with no related prefix") }
                .to raise_error(NoMatchingSprintPrefixError,
                                /#{Regexp.escape(
                                  "No matching sprint prefix for team 'team with no related prefix' in "
                                )}
                                  #{Regexp.escape(expected_team_sprint_prefix_mappings.inspect)}/x)
            end
          end

          describe "#map_prefix_name_to_team_name" do
            it { expect(mapper.map_prefix_name_to_team_name("ART-16_CRM")).to eq "A16 CRM" }
            it { expect(mapper.map_prefix_name_to_team_name("ART-32-64_Sys-Team")).to eq "A32 64 Sys-Team" }

            it "raises an error if the prefix is not found" do
              expect { mapper.map_prefix_name_to_team_name("team-unrelated-prefix") }.not_to raise_error
            end
          end

          describe "#list_mappings" do
            let(:expected_mapping_output) do
              <<~EOMAPPING
                +-----------------------------------------------------+
                |                Team Sprint Mappings                 |
                +-----------------+-----------------------------------+
                | Team            | Sprint Prefix                     |
                +-----------------+-----------------------------------+
                | A16 CRM         | ART-16_CRM                        |
                | A16 Logistic    | !!__no matching sprint prefix__!! |
                | A16 Platform    | ART-16_Platform                   |
                | A32 64 Sys-Team | ART-32-64_Sys-Team                |
                +-----------------+-----------------------------------+
              EOMAPPING
            end

            it "lists the mappings" do
              allow(mapper).to receive_messages(team_sprint_prefix_mappings: expected_team_sprint_prefix_mappings)

              expect { mapper.list_mappings }.to output(expected_mapping_output).to_stdout
            end
          end
        end
      end
    end
  end
end
