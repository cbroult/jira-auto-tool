# frozen_string_literal: true

require "jira/auto/tool/board_controller"

module Jira
  module Auto
    class Tool
      class Board
        # rubocop:disable  RSpec/MultipleMemoizedHelpers
        RSpec.describe BoardController do
          let(:jira_client) { instance_double(JIRA::Client) }
          let(:tool) { instance_double(Tool, jira_client: jira_client) }
          let(:board_controller) { described_class.new(tool) }

          let(:board_info) do
            [
              ["Board 1", "ART", "https://jira.example.com/projects/ART/boards/1"],
              ["Board 2", "ART ", "https://jira.example.com/projects/ART/boards/2"],
              ["Board 3", "TOOL", "https://jira.example.com/projects/TOOL/boards/3"]
            ]
          end

          describe "#list_boards" do
            let(:boards) do
              board_info.collect do |name, project_key, url|
                instance_double(Board, name:, project_key:, url:)
              end
            end

            let(:expected_board_list) do
              <<~EOBL
                +---------+-------------+-------------------------------------------------+
                |                                 Boards                                  |
                +---------+-------------+-------------------------------------------------+
                | Name    | Project Key | Board URL                                       |
                +---------+-------------+-------------------------------------------------+
                | Board 1 | ART         | https://jira.example.com/projects/ART/boards/1  |
                | Board 2 | ART         | https://jira.example.com/projects/ART/boards/2  |
                | Board 3 | TOOL        | https://jira.example.com/projects/TOOL/boards/3 |
                +---------+-------------+-------------------------------------------------+
              EOBL
            end

            before do
              allow(board_controller).to receive_messages(boards: boards)
            end

            it { expect { board_controller.list_boards }.to output(expected_board_list).to_stdout }
          end

          describe "#boards" do
            let(:jira_boards) do
              board_info.collect do |name, project_key, url|
                jira_resource_double(JIRA::Resource::Board, name:, project_key:, url:)
              end
            end

            let(:query) { jira_resource_double(all: jira_boards) }

            before do
              allow(jira_client).to receive_messages(Board: query)
            end

            it("returns the boards") { expect(board_controller.boards).to all be_a(Board) }
          end
        end
      end
    end
    # rubocop:enable  RSpec/MultipleMemoizedHelpers
  end
end
