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
              [[1, "1st sprint"], [2, "2nd sprint"]]
                .collect { |id, name| double(JIRA::Resource::Sprint, id: id, name: name, state: "closed") } # rubocop:disable RSpec/VerifiedDoubles
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

        describe "#sprints" do
          let(:jira_sprints) do
            [
              [1, "ART-16_E2E-Test_24.4.1"],
              [2, "ART-16_CRM_24.4.1"],
              [3, "ART-16_E2E-Test_24.4.2"],
              [4, "ART-32_Platform_24.4.7"],
              [5, "ART-32_Sys-Team_24.4.12"],
              [6, "ART-32_Sys-Team_25.1.1"],
              [2, "ART-16_CRM_24.4.1"],
              [3, "ART-16_E2E-Test_24.4.2"]
            ].collect { |id, name| jira_resource_double(Sprint, id: id, name: name) }
          end

          before do
            allow(sprint_controller).to receive_messages(jira_sprints: jira_sprints)
          end

          it "returns the sprints" do
            expect(sprint_controller.sprints).to all be_a(Sprint)
          end

          it "eliminates duplicates (e.g., related to a sprint showing up on several boards)" do
            expect(sprint_controller.sprints.collect(&:name)).to eq(%w[
                                                                      ART-16_CRM_24.4.1
                                                                      ART-16_E2E-Test_24.4.1
                                                                      ART-16_E2E-Test_24.4.2
                                                                      ART-32_Platform_24.4.7
                                                                      ART-32_Sys-Team_24.4.12
                                                                      ART-32_Sys-Team_25.1.1
                                                                    ])
          end

          context "when looking at the sprint order" do
            let(:jira_sprints) do
              [
                [16, "ART-32_Sys-Team_24.4.2", 7, "2024-05-15", "2024-05-22"],
                [32, "1st sprint", 14, "2024-05-01", "2024-05-15"],
                [64, "2nd sprint", 7, "2024-05-15", "2024-05-22"],
                [128, "Non compliant sprint name", 7, "2024-05-15", "2024-05-22"],
                [256, "ART-16_E2E_25.1.2", 7, "2024-05-15", "2024-05-22"]
              ].collect do |id, name, _length_in_days, start_date, end_date|
                jira_resource_double(JIRA::Resource::Sprint, id: id, name: name, startDate: start_date,
                                                             endDate: end_date)
              end
            end

            let(:expected_sorted_sprint_names) do
              [
                "1st sprint",
                "2nd sprint",
                "ART-16_E2E_25.1.2",
                "ART-32_Sys-Team_24.4.2",
                "Non compliant sprint name"
              ]
            end

            before do
              allow(sprint_controller).to receive_messages(jira_sprints: jira_sprints)
            end

            it "returns sorted sprints" do
              expect(sprint_controller.sprints.collect(&:name)).to eq(expected_sorted_sprint_names)
            end
          end
        end

        describe "#list_sprints" do
          let(:matching_sprints) do
            [
              ["1st sprint", 14, "2024-05-01", "2024-05-15", "board info 1", "board info 2"],
              ["2nd sprint", 7, "2024-05-15", "2024-05-22", "board info 3", "board info 4"]
            ]
              .collect { |row_info| instance_double(Sprint, to_table_row: row_info, state: "future") }
          end

          let(:expected_sprint_table) do
            <<~END_OF_TABLE
              +------------+----------------+------------+------------+---------------+---------------+
              |                                   Matching Sprints                                    |
              +------------+----------------+------------+------------+---------------+---------------+
              | Sprint     | Length In Days | Start Date | End Date   | Board Column1 | Board Column2 |
              +------------+----------------+------------+------------+---------------+---------------+
              | 1st sprint | 14             | 2024-05-01 | 2024-05-15 | board info 1  | board info 2  |
              | 2nd sprint | 7              | 2024-05-15 | 2024-05-22 | board info 3  | board info 4  |
              +------------+----------------+------------+------------+---------------+---------------+
            END_OF_TABLE
          end

          before do
            allow(sprint_controller).to receive_messages(sprints: matching_sprints)
          end

          it "list the matching sprints as a table" do
            allow(Sprint).to receive_messages(
              to_table_row_header: ["Sprint", "Length In Days", "Start Date", "End Date",
                                    "Board Column1", "Board Column2"]
            )
            expect { sprint_controller.list_sprints }.to output(expected_sprint_table).to_stdout
          end

          it "can be called so that the board information is excluded" do
            allow(Sprint).to receive(:to_table_row_header).with(without_board_information: true).and_return([:name])

            # rubocop:disable RSpec / MessageExpectation
            expect(matching_sprints).to all receive(:to_table_row).with(without_board_information: true) # rubocop:disable RSpec/MessageSpies
            # rubocop:enable RSpec / MessageExpectation

            allow($stdout).to receive_messages(puts: nil)

            sprint_controller.list_sprints(without_board_information: true)
          end
        end

        describe "#list_sprint_prefixes" do
          let(:sprint_prefixes) do
            [
              ["Food_Delivery", "Food_Delivery_25.2.3", 7, "2024-05-15", "2024-05-22", "board info 3", "board info 4"],
              ["Food_Supply", "Food_Supply_25.2.2", 14, "2024-05-01", "2024-05-15", "board info 1", "board info 2"]
            ]
              .collect { |row_info| instance_double(Sprint::Prefix, to_table_row: row_info) }
          end

          let(:expected_sprint_prefix_table) do
            <<~END_OF_TABLE
              +---------------+----------------------+----------------+------------+------------+---------------+---------------+
              |                                 Sprint Prefixes With Corresponding Last Sprints                                 |
              +---------------+----------------------+----------------+------------+------------+---------------+---------------+
              | Sprint Prefix | Last Sprint Name     | Length In Days | Start Date | End Date   | Board Column1 | Board Column2 |
              +---------------+----------------------+----------------+------------+------------+---------------+---------------+
              | Food_Delivery | Food_Delivery_25.2.3 | 7              | 2024-05-15 | 2024-05-22 | board info 3  | board info 4  |
              | Food_Supply   | Food_Supply_25.2.2   | 14             | 2024-05-01 | 2024-05-15 | board info 1  | board info 2  |
              +---------------+----------------------+----------------+------------+------------+---------------+---------------+
            END_OF_TABLE
          end

          before { allow(sprint_controller).to receive_messages(unclosed_sprint_prefixes: sprint_prefixes) }

          it "list the sprint prefixes as a table" do
            allow(Sprint::Prefix).to receive_messages(
              to_table_row_header: ["Sprint Prefix", "Last Sprint Name", "Length In Days", "Start Date", "End Date",
                                    "Board Column1", "Board Column2"]
            )

            expect { sprint_controller.list_sprint_prefixes }.to output(expected_sprint_prefix_table).to_stdout
          end

          it "can be called so that the board information is excluded" do
            allow(Sprint::Prefix)
              .to receive(:to_table_row_header).with(without_board_information: true).and_return([:name])

            # rubocop:disable RSpec / MessageExpectation
            expect(sprint_prefixes).to all receive(:to_table_row).with(without_board_information: true) # rubocop:disable RSpec/MessageSpies
            # rubocop:enable RSpec / MessageExpectation

            allow($stdout).to receive_messages(puts: nil)

            sprint_controller.list_sprint_prefixes(without_board_information: true)
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

            allow(sprint_controller).to receive_messages(unfiltered_board_sprints: all_sprints)
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

        # rubocop:disable RSpec / MultipleMemoizedHelpers
        describe "#unclosed_sprint_prefixes" do
          def new_jira_sprints(name_start_end_trios)
            name_start_end_trios.collect do |id, name, start_data, end_date|
              jira_resource_double(JIRA::Resource::Sprint,
                                   id: id, name: name, startDate: start_data, endDate: end_date, state: "future")
            end
          end

          def new_sprints(jira_sprints)
            jira_sprints.collect { |jira_sprint| Sprint.new(tool, jira_sprint) }
          end

          let(:e2e_jira_sprints) do
            new_jira_sprints [
              [1, "art_e2e_25.1.2", "2024-12-08", "2024-12-14"]
            ]
          end

          let(:sys_jira_sprints) do
            new_jira_sprints [
              [2, "art_sys_24.4.8", "2024-12-15", "2024-12-22"],
              [3, "art_sys_24.4.9", "2024-12-22", "2024-12-29"]
            ]
          end

          let(:jira_sprints) { sys_jira_sprints + e2e_jira_sprints }

          let(:art_e2e_prefix) { Sprint::Prefix.new("art_e2e", new_sprints(e2e_jira_sprints)) }
          let(:art_sys_prefix) { Sprint::Prefix.new("art_sys", new_sprints(sys_jira_sprints)) }

          it "groups sprints as per their prefix" do
            allow(sprint_controller).to receive_messages(jira_sprints: jira_sprints)

            expect(sprint_controller.unclosed_sprint_prefixes).to contain_exactly(art_e2e_prefix, art_sys_prefix)
          end

          it "provides the sprint prefixes sorted by their name" do
            allow(sprint_controller)
              .to receive_messages(calculate_unclosed_sprint_prefixes: [art_sys_prefix, art_e2e_prefix])

            expect(sprint_controller.unclosed_sprint_prefixes.collect(&:name)).to eq(%w[art_e2e art_sys])
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

        describe "#sprint_compatible_boards" do
          let(:boards) do
            [
              ["scrum board_1", true],
              ["kanban board_2", false],
              ["scrum board_3", true],
              ["simple board_4", false]
            ].collect do |name, sprint_compatible|
              instance_double(Board, name: name, sprint_compatible?: sprint_compatible)
            end
          end

          before { allow(sprint_controller).to receive_messages(boards: boards) }

          it { expect(sprint_controller.sprint_compatible_boards).to all be_sprint_compatible }
        end

        describe "#unfiltered_jira_sprints" do
          it "deals with JIRA::Resource pagination" do
            allow(sprint_controller)
              .to receive(:fetch_jira_sprints).with(board, 50, 0).and_return(%w[sprint_1 sprint_2])

            allow(sprint_controller)
              .to receive(:fetch_jira_sprints).with(board, 50, 50).and_return(%w[sprint_3 sprint_4])

            allow(sprint_controller)
              .to receive(:fetch_jira_sprints).with(board, 50, 100).and_return([])

            expect(sprint_controller.unfiltered_jira_sprints(board)).to eq(%w[sprint_1 sprint_2 sprint_3 sprint_4])
          end
        end

        describe "#fetch_jira_sprints" do
          let(:jira_board) { jira_resource_double(JIRA::Resource::Board, sprints: []) }

          before do
            allow(board).to receive_messages(jira_board: jira_board)
          end

          it "gets the next batch of sprints" do
            sprint_controller.fetch_jira_sprints(board, 512, 1024)

            expect(jira_board).to have_received(:sprints).with(maxResults: 512, startAt: 1024)
          end
        end
      end
    end

    # rubocop:enable Metrics/ClassLength
  end
end
