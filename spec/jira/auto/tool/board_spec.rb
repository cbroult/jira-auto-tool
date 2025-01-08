# frozen_string_literal: true

require "jira/auto/tool/board"

module Jira
  module Auto
    class Tool
      class Board
        RSpec.describe Board do
          let(:jira_client) { instance_double(JIRA::Client) }
          let(:tool) { instance_double(Tool, jira_client: jira_client) }
          let(:project) { { "key" => "PROJECT_KEY" } }

          let(:jira_board) do
            jira_resource_double(JIRA::Resource::Board, name: "board name", project: project, url: "BOARD_URL")
          end

          let(:board) { described_class.new(tool, jira_board) }

          it { expect(board.name).to eq("board name") }
          it { expect(board.project_key).to eq("PROJECT_KEY") }
          it { expect(board.url).to eq("BOARD_URL") }
        end
      end
    end
  end
end
