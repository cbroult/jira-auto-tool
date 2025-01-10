# frozen_string_literal: true

require "jira/auto/tool/sprint_controller"

module Jira
  module Auto
    # rubocop:disable Metrics/ClassLength
    class Tool
      RSpec.describe SprintController do
        let(:tool) { instance_double(Tool) }
        let(:board) { double(JIRA::Resource::Board, name: "board name", id: 128) } # rubocop:disable RSpec/VerifiedDoubles
        let(:sprint_controller) { described_class.new(tool, board) }

        describe "#add_sprints_until" do
          let(:actual_sprint_prefixes) do
            %w[art_team1 art_team2 art_team3].collect do |name_prefix|
              instance_double(Sprint::Prefix, name: name_prefix, add_sprints_until: nil)
            end
          end

          it "creates sprints for all unclosed prefixes until date is included" do
            allow(sprint_controller).to receive_messages(unclosed_sprint_prefixes: actual_sprint_prefixes)

            sprint_controller.add_sprints_until("2024-05-15")

            expect(actual_sprint_prefixes).to all have_received(:add_sprints_until).with("2024-05-15")
          end
        end

        describe "#add_one_sprint_for_each_unclosed_sprint_prefix" do
          context "when no sprint are found" do
            it "exits with a warning" do
              allow(sprint_controller).to receive_messages(sprints: [])
              allow(sprint_controller).to receive_messages(exit_with_board_warning: nil)

              sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix

              expect(sprint_controller).to have_received(:exit_with_board_warning)
                .with("No sprint added since no reference sprint was found!")
            end
          end

          context "when only closed sprint are found" do
            let(:closed_sprints) do
              ["1st sprint", "2nd sprint"]
                .collect { |name| double(JIRA::Resource::Sprint, name: name, state: "closed") } # rubocop:disable RSpec/VerifiedDoubles
            end

            it "exits with a warning" do
              allow(sprint_controller).to receive_messages(jira_sprints: closed_sprints)
              allow(sprint_controller).to receive_messages(exit_with_board_warning: nil)

              sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix

              expect(sprint_controller).to have_received(:exit_with_board_warning)
                .with("No sprint added since no unclosed reference sprint was found!")
            end
          end

          context "when unclosed sprint are found" do
            let(:actual_sprint_prefixes) do
              ["1st sprint_prefix", "3rd sprint_prefix"].collect do |prefix_name|
                instance_double(Sprint::Prefix, name: prefix_name, add_sprint_following_last_one: nil)
              end
            end

            it "add a sprint for the sprint prefixes having at least one unclosed sprint" do
              allow(sprint_controller).to receive_messages(sprint_exist?: true, unclosed_sprint_exist?: true)
              allow(sprint_controller).to receive_messages(unclosed_sprint_prefixes: actual_sprint_prefixes)

              sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix

              expect(actual_sprint_prefixes).to all have_received(:add_sprint_following_last_one)
            end
          end
        end

        # rubocop:disable RSpec / MultipleMemoizedHelpers
        describe "#jira_sprints" do
          let(:all_sprints) do
            %w[
              ART-16_E2E-Test_24.4.1
              ART-16_CRM_24.4.1
              ART-16_E2E-Test_24.4.2
              ART-32_Platform_24.4.7
              ART-32_Sys-Team_24.4.12
              ART-32_Sys-Team_25.1.1
            ].collect { |name| jira_resource_double(Sprint, name: name) }
          end
          let(:art_sprint_regex_defined?) { false }
          let(:art_sprint_regex) { nil }

          before do
            allow(tool)
              .to receive_messages(art_sprint_regex_defined?: art_sprint_regex_defined?,
                                   art_sprint_regex: art_sprint_regex)

            allow(sprint_controller).to receive_messages(unfiltered_jira_sprints: all_sprints)
          end

          context "when no filter specified" do
            it { expect(sprint_controller.jira_sprints).to eq(all_sprints) }
          end

          context "when filter specified" do
            let(:art_sprint_regex_defined?) { true }

            context "when using a string" do
              let(:art_sprint_regex) { "ART-16" }

              it do
                expect(sprint_controller.jira_sprints.collect(&:name))
                  .to eq(%w[
                           ART-16_E2E-Test_24.4.1
                           ART-16_CRM_24.4.1
                           ART-16_E2E-Test_24.4.2
                         ])
              end
            end

            context "when using a regex" do
              let(:art_sprint_regex) { "E2E|Sys" }

              it do
                expect(sprint_controller.jira_sprints.collect(&:name))
                  .to eq(%w[
                           ART-16_E2E-Test_24.4.1
                           ART-16_E2E-Test_24.4.2
                           ART-32_Sys-Team_24.4.12
                           ART-32_Sys-Team_25.1.1
                         ])
              end
            end
          end
        end
        # rubocop:enable RSpec / MultipleMemoizedHelpers

        describe "#list_sprints" do
          context "when displaying on the console" do
            let(:matching_sprints) do
              ["1st sprint", "2nd sprint"].collect { |name| instance_double(Sprint, name: name) }
            end

            let(:expected_sprint_table) do
              <<~END_OF_TABLE
                +------------------+
                | Matching Sprints |
                +------------------+
                | Sprint           |
                +------------------+
                | 1st sprint       |
                | 2nd sprint       |
                +------------------+
              END_OF_TABLE
            end

            before { allow(sprint_controller).to receive_messages(sprints: matching_sprints) }

            it "list the matching sprints as a table" do
              expect { sprint_controller.list_sprints }.to output(expected_sprint_table).to_stdout
            end
          end
        end

        # rubocop:disable RSpec / MultipleMemoizedHelpers
        describe "#unclosed_sprint_prefixes" do
          def new_jira_sprints(name_start_end_trios)
            name_start_end_trios.collect do |name, start_data, end_date|
              jira_resource_double(JIRA::Resource::Sprint,
                                   name: name, startDate: start_data, endDate: end_date, state: "future")
            end
          end

          def new_sprints(jira_sprints)
            jira_sprints.collect do |jira_sprint|
              Sprint.new(jira_sprint)
            end
          end

          let(:e2e_jira_sprints) do
            new_jira_sprints [
              ["art_e2e_25.1.2", "2024-12-08", "2024-12-14"]
            ]
          end

          let(:sys_jira_sprints) do
            new_jira_sprints [
              ["art_sys_24.4.8", "2024-12-15", "2024-12-22"],
              ["art_sys_24.4.9", "2024-12-22", "2024-12-29"]
            ]
          end

          let(:jira_sprints) { e2e_jira_sprints + sys_jira_sprints }

          it "groups sprints as per their prefix" do
            allow(sprint_controller).to receive_messages(jira_sprints: jira_sprints)

            expect(sprint_controller.unclosed_sprint_prefixes)
              .to contain_exactly(
                Sprint::Prefix.new("art_e2e", new_sprints(e2e_jira_sprints)),
                Sprint::Prefix.new("art_sys", new_sprints(sys_jira_sprints))
              )
          end
        end
        # rubocop:enable RSpec / MultipleMemoizedHelpers

        describe "#sprint_exist?" do
          let(:examples) do
            [
              [true, %w[sprint_1 sprint_2]],
              [false, []]
            ]
          end

          it "behaves as expected" do
            examples.each do |expected_result, sprints|
              allow(sprint_controller).to receive_messages(sprints: sprints)

              expect(sprint_controller.sprint_exist?).to eq(expected_result)
            end
          end
        end

        describe "#unfiltered_jira_sprints" do
          it "deals with JIRA::Resource pagination" do
            allow(sprint_controller)
              .to receive(:fetch_jira_sprints).with(50, 0).and_return(%w[sprint_1 sprint_2])

            allow(sprint_controller)
              .to receive(:fetch_jira_sprints).with(50, 50).and_return(%w[sprint_3 sprint_4])

            allow(sprint_controller)
              .to receive(:fetch_jira_sprints).with(50, 100).and_return([])

            expect(sprint_controller.unfiltered_jira_sprints).to eq(%w[sprint_1 sprint_2 sprint_3 sprint_4])
          end
        end

        describe "#fetch_jira_sprints" do
          let(:sprint_query) { double("sprint_query", all: %w[sprint_1 sprint_2]) } # rubocop:disable RSpec/VerifiedDoubles

          let(:jira_client) { instance_double(JIRA::Client, Sprint: sprint_query) }

          before do
            allow(tool).to receive_messages(jira_client: jira_client)
          end

          it "gets the next batch of sprints" do
            sprint_controller.fetch_jira_sprints(512, 1024)

            expect(sprint_query).to have_received(:all).with(maxResults: 512, startAt: 1024)
          end

          # rubocop:disable RSpec/MultipleMemoizedHelpers:
          context "when no more sprints are available" do
            let(:response) { instance_double(Net::HTTPResponse, message: "null for uri:") }

            before do
              allow(sprint_query).to receive(:all).and_raise(JIRA::HTTPError, response)
            end

            it "returns an empty array" do
              expect(sprint_controller.fetch_jira_sprints(50, 4096)).to eq([])
            end
          end
          # rubocop:enable RSpec/MultipleMemoizedHelpers:
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
