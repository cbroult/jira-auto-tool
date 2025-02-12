# frozen_string_literal: true

require "jira/auto/tool/board_controller"

module Jira
  module Auto
    class Tool
      class BoardController
        # rubocop:disable  RSpec/MultipleMemoizedHelpers
        RSpec.describe BoardController do
          let(:jira_client) { instance_double(JIRA::Client) }
          let(:jira_boards) do
            board_info.collect do |name, project_key, url|
              jira_resource_double(JIRA::Resource::Board, name:, project_key:, url:)
            end
          end

          let(:expected_boards) do
            board_info.collect do |name, project_key, url, with_project_information|
              build_board(name, project_key, url, with_project_information: with_project_information)
            end
          end

          let(:tool) { instance_double(Tool, jira_client: jira_client) }
          let(:board_controller) { described_class.new(tool) }

          let(:board_info) do
            [
              ["Board 1", "ART", "https://jira.example.com/projects/ART/boards/1", true],
              ["Board 2", "ART", "https://jira.example.com/projects/ART/boards/2", true],
              ["Board 3", "TOOL", "https://jira.example.com/projects/TOOL/boards/3", true],
              ["Board 4", "N/A", "https://jira.example.com/projects/TOOL/boards/4", false]
            ]
          end

          def build_board(name, project_key, ui_url, with_project_information: true)
            instance_double(Board, name:, project_key:, ui_url:, with_project_information?: with_project_information,
                                   inspect: name)
          end

          describe "#list_boards" do
            let(:expected_board_list) do
              <<~EOBL
                +-------------------------------------------------------------------------+
                |                                 Boards                                  |
                +-------------+---------+-------------------------------------------------+
                | Project Key | Name    | Board UI URL                                    |
                +-------------+---------+-------------------------------------------------+
                | ART         | Board 1 | https://jira.example.com/projects/ART/boards/1  |
                | ART         | Board 2 | https://jira.example.com/projects/ART/boards/2  |
                | TOOL        | Board 3 | https://jira.example.com/projects/TOOL/boards/3 |
                | N/A         | Board 4 | https://jira.example.com/projects/TOOL/boards/4 |
                +-------------+---------+-------------------------------------------------+
              EOBL
            end

            before do
              allow(board_controller).to receive_messages(boards: expected_boards)
            end

            it { expect { board_controller.list_boards }.to output(expected_board_list).to_stdout }
          end

          describe "#boards" do
            let(:project_key) { nil }
            let(:board_name_regex) { nil }

            before do
              allow(board_controller).to receive_messages(unfiltered_boards: expected_boards)

              allow(tool).to receive_messages(
                jira_board_name_regex: board_name_regex,
                jira_board_name_regex_defined?: board_name_regex,
                jira_project_key: project_key,
                jira_project_key_defined?: project_key
              )
            end

            context "when using board name filtering" do
              context "when a board name regex is specified" do
                let(:board_name_regex) { "1|3" }

                it { expect(board_controller.boards).to eq(expected_boards.find_all { |b| b.name !~ /Board (2|4)/ }) }
              end

              context "when no board name regex is specified" do
                it { expect(board_controller.boards).to eq(expected_boards) }
              end
            end

            context "when using project key filtering" do
              context "when a project key is specified" do
                let(:project_key) { "ART" }
                let(:board_expected_to_be_excluded) do
                  build_board("Board 3", "ART", "https://jira.example.com/projects/ART/boards/3")
                end

                it { expect(board_controller.boards).to eq(expected_boards.find_all { |b| b.name != "Board 3" }) }
                it { expect(board_controller.boards).not_to include(board_expected_to_be_excluded) }
              end

              context "when no project key is specified" do
                it { expect(board_controller.boards).to eq(expected_boards) }
              end
            end
          end

          describe "#unfiltered_boards" do
            let(:query) { jira_resource_double(all: jira_boards) }

            before do
              allow(jira_client).to receive_messages(Board: query)
            end

            it("returns boards") { expect(board_controller.unfiltered_boards).to all be_a(Board) }
          end
        end
      end
    end

    # rubocop:enable  RSpec/MultipleMemoizedHelpers
  end
end
