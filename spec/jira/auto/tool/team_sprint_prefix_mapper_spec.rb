# frozen_string_literal: true

require "rspec"

module Jira
  module Auto
    class Tool
      class TeamSprintPrefixMapper
        # rubocop:disable RSpec/MultipleMemoizedHelpers
        RSpec.describe TeamSprintPrefixMapper do
          let(:mapper) do
            described_class.new(teams, unclosed_sprint_prefixes)
          end

          let(:team_names) { ["A16 CRM", "A16 Logistic", "A16 Platform", "A32 64 Sys-Team"] }
          let(:teams) { team_names.collect { |name| instance_double(Team, name: name) } }

          let(:expected_team_sprint_prefix_mappings) do
            {
              "A16 CRM" => "ART-16_CRM",
              "A16 Platform" => "ART-16_Platform",
              "A32 64 Sys-Team" => "ART-32-64_Sys-Team"
            }
          end

          let(:sprint_controller) do
            instance_double(SprintController,
                            unclosed_sprint_prefixes: unclosed_sprint_prefixes)
          end

          let(:unclosed_sprint_prefix_names) { %w[ART-16_CRM ART-16_Platform ART-32-64_Sys-Team] }

          let(:unclosed_sprint_prefixes) do
            unclosed_sprint_prefix_names.collect { |name| instance_double(Sprint::Prefix, name: name) }
          end

          let(:tool) do
            instance_double(Tool,
                            implementation_team_field: team_field,
                            sprint_controller: sprint_controller,
                            teams: teams)
          end
          let(:team_field) { instance_double(Field, name: "team_name") }

          def build_sprint(name)
            instance_double(Sprint, name: name, name_prefix: name.sub(/_[^_]+$/, ""))
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

          describe "#map_prefix_name_to_team_name" do
            it { expect(mapper.map_prefix_name_to_team_name("ART-16_CRM")).to eq "A16 CRM" }
            it { expect(mapper.map_prefix_name_to_team_name("ART-32-64_Sys-Team")).to eq "A32 64 Sys-Team" }

            it "raises an error if the prefix is not found" do
              expect { mapper.map_prefix_name_to_team_name("team-unrelated-prefix") }
                .to raise_error(NoMatchingTeamError,
                                /No\smatching\steam\sfound\sfor\sprefix\s'team-unrelated-prefix'\sin\s
                                  #{Regexp.escape(team_names.inspect)}/x)
            end
          end

          describe "#list_mappings" do
            let(:expected_mapping_output) do
              <<~EOMAPPING
                +-----------------+-----------------------------------+
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
              allow(mapper).to receive_messages(team_sprint_mappings: expected_team_sprint_prefix_mappings)

              expect { mapper.list_mappings }.to output(expected_mapping_output).to_stdout
            end
          end
        end
        # rubocop:enable RSpec/MultipleMemoizedHelpers
      end
    end
  end
end
