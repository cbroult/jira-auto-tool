# frozen_string_literal: true

require "jira/auto/tool/sprint_controller"

module Jira
  module Auto
    class Tool
      RSpec.describe SprintController do
        let(:board) { double(JIRA::Resource::Board, name: "board name") } # rubocop:disable RSpec/VerifiedDoubles
        let(:sprint_controller) { described_class.new(board) }

        describe "#add_one_sprint_for_each_unclosed_sprint_prefix" do
          let(:expected_sprint_prefixes) do
            [
              "1st sprint_prefix",
              "2nd sprint_prefix",
              "3rd sprint_prefix"
            ].collect { |prefix_name| instance_double(prefix_name, add_one_sprint: nil) }
          end

          let(:closed_sprints) do
            [
              "1st sprint",
              "2nd sprint",
              "3rd sprint"
            ].collect { |name| double(JIRA::Resource::Sprint, name: name, state: "closed") } # rubocop:disable RSpec/VerifiedDoubles
          end

          it "warns when no sprint found" do
            allow(board).to receive_messages(sprints: [])
            allow(sprint_controller).to receive_messages(exit_with_board_warning: nil)

            sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix

            expect(sprint_controller).to have_received(:exit_with_board_warning)
              .with("No sprint added since no reference sprint was found!")
          end

          it "warns when only closed sprint are found" do
            allow(board).to receive_messages(sprints: closed_sprints)
            allow(sprint_controller).to receive_messages(exit_with_board_warning: nil)

            sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix

            expect(sprint_controller).to have_received(:exit_with_board_warning)
              .with("No sprint added since no unclosed reference sprint was found!")
          end

          it "add a sprint for the sprint prefixes having at least one unclosed sprint" do
            allow(sprint_controller).to receive_messages(sprint_exist?: true, unclosed_sprint_exist?: true)
            allow(sprint_controller).to receive_messages(unclosed_sprint_prefixes: expected_sprint_prefixes)

            sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix

            expect(expected_sprint_prefixes).to all have_received(:add_one_sprint)
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

        describe "#calculate_sprint_prefix_name" do
          let(:expectation_examples) do
            [
              ["Team", "Team_24.4.1"],
              ["ART_Team", "ART_Team_24.4.1"],
              ["Solution_ART_Team", "Solution_ART_Team_24.4.1"]
            ]
          end

          it "behaves as expected" do
            expectation_examples.each do |expected_prefix, sprint_name|
              expect(sprint_controller.calculate_sprint_prefix_name(sprint_name)).to eq(expected_prefix)
            end
          end

          it "raise an error if the prefix is not found" do
            expect { sprint_controller.calculate_sprint_prefix_name("name ignoring naming convention") }
              .to raise_error(SprintController::SprintNameError,
                              "'name ignoring naming convention': " \
                              "sprint name expected to include at least one '_' character!")
          end
        end
      end
    end
  end
end
