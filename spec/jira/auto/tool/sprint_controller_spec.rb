# frozen_string_literal: true

require "jira/auto/tool/sprint_controller"

module Jira
  module Auto
    # rubocop:disable Metrics/ClassLength

    class Tool
      RSpec.describe SprintController do
        let(:board) { double(JIRA::Resource::Board, name: "board name", id: 128) } # rubocop:disable RSpec/VerifiedDoubles
        let(:sprint_controller) { described_class.new(board) }

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

        describe "#unclosed_sprint_prefixes" do
          def new_jira_sprints(name_start_pairs)
            name_start_pairs.collect do |name, start|
              double(JIRA::Resource::Sprint, name: name, start: start, state: "future") # rubocop:disable RSpec/VerifiedDoubles
            end
          end

          def new_sprints(jira_sprints)
            jira_sprints.collect do |jira_sprint|
              Sprint.new(jira_sprint, board_id: 512)
            end
          end

          let(:e2e_jira_sprints) do
            new_jira_sprints [
              ["art_e2e_25.1.2", "2024-12-08"]
            ]
          end

          let(:sys_jira_sprints) do
            new_jira_sprints [
              ["art_sys_24.4.8", "2024-12-15"],
              ["art_sys_24.4.9", "2024-12-22"]
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

        describe "#jira_sprints" do
          it "deals with JIRA::Resource pagination" do
            allow(board)
              .to receive(:sprints).with(maxResults: 1000, startAt: 0).and_return(%w[sprint_1 sprint_2])

            allow(board)
              .to receive(:sprints).with(maxResults: 1000, startAt: 1000).and_return(%w[sprint_3 sprint_4])

            allow(board)
              .to receive(:sprints).with(maxResults: 1000, startAt: 2000).and_return([])

            expect(sprint_controller.jira_sprints).to eq(%w[sprint_1 sprint_2 sprint_3 sprint_4])
          end
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
