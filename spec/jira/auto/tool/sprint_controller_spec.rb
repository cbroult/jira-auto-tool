# frozen_string_literal: true

require "jira/auto/tool/sprint_controller"

module Jira
  module Auto
    class Tool
      RSpec.describe SprintController do
        let(:board) { double(JIRA::Resource::Board, name: "board name", id: 128) } # rubocop:disable RSpec/VerifiedDoubles
        let(:sprint_controller) { described_class.new(board) }

        describe "#add_one_sprint_for_each_unclosed_sprint_prefix" do
          context "when no sprint are found" do
            it "exits with a warning" do
              allow(board).to receive_messages(sprints: [])
              allow(sprint_controller).to receive_messages(exit_with_board_warning: nil)

              sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix

              expect(sprint_controller).to have_received(:exit_with_board_warning)
                .with("No sprint added since no reference sprint was found!")
            end
          end

          context "when only closed sprint are found" do
            let(:closed_sprints) do
              [
                "1st sprint",
                "2nd sprint",
                "3rd sprint"
              ].collect { |name| double(JIRA::Resource::Sprint, name: name, state: "closed") } # rubocop:disable RSpec/VerifiedDoubles
            end

            it "exits with a warning" do
              allow(board).to receive_messages(sprints: closed_sprints)
              allow(sprint_controller).to receive_messages(exit_with_board_warning: nil)

              sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix

              expect(sprint_controller).to have_received(:exit_with_board_warning)
                .with("No sprint added since no unclosed reference sprint was found!")
            end
          end

          context "when unclosed sprint are found" do
            let(:expected_sprint_prefixes) do
              [
                "1st sprint_prefix",
                "2nd sprint_prefix",
                "3rd sprint_prefix"
              ].collect { |prefix_name| instance_double(prefix_name, add_one_sprint: nil) }
            end

            it "add a sprint for the sprint prefixes having at least one unclosed sprint" do
              allow(sprint_controller).to receive_messages(sprint_exist?: true, unclosed_sprint_exist?: true)
              allow(sprint_controller).to receive_messages(unclosed_sprint_prefixes: expected_sprint_prefixes)
              allow(NextSprintCreator).to receive_messages(create_sprint_following: nil)

              sprint_controller.add_one_sprint_for_each_unclosed_sprint_prefix

              expected_sprint_prefixes.each do |sprint_prefix|
                expect(NextSprintCreator).to have_received(:create_sprint_following).with(sprint_prefix)
              end
            end
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
      end
    end
  end
end
