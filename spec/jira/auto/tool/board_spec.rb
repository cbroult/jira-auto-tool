# frozen_string_literal: true

require "jira/auto/tool/board"

module Jira
  module Auto
    class Tool
      class Board
        RSpec.describe Board do
          let(:jira_client) { instance_double(JIRA::Client) }
          let(:tool) { instance_double(Tool, jira_client: jira_client) }

          let(:jira_board) do
            jira_resource_double(JIRA::Resource::Board, name: "board name", url: "BOARD_URL", id: 4)
          end

          let(:board) { described_class.new(tool, jira_board) }

          it { expect(board.name).to eq("board name") }

          it { expect(board.url).to eq("BOARD_URL") }

          it { expect(board.id).to eq(4) }

          describe "#ui_url" do
            context "when location information is available" do
              before do
                allow(board).to receive_messages(with_project_information?: false)

                allow(tool)
                  .to receive(:jira_url).with("/secure/RapidBoard.jspa?rapidView=4")
                                        .and_return("https://a-jira-site.example.com/jira/secure/RapidBoard.jspa?rapidView=4")
              end

              it do
                expect(board.ui_url)
                  .to eq("https://a-jira-site.example.com/jira/secure/RapidBoard.jspa?rapidView=4")
              end
            end

            context "when location information is not available" do
              # TODO: - fix the URL
              before do
                allow(board).to receive_messages(with_project_information?: true, project_key: "PROJECT_KEY")

                allow(tool)
                  .to receive(:jira_url).with("/board/PROJECT_KEY/board/4")
                                        .and_return("https://a-jira-site.example.com/jira/board/PROJECT_KEY/board/4")
              end

              it do
                expect(board.ui_url)
                  .to eq("https://a-jira-site.example.com/jira/board/PROJECT_KEY/board/4")
              end
            end
          end

          describe "#project_key" do
            context "when location information is available" do
              before do
                allow(jira_board)
                  .to receive_messages(with_project_information?: true,
                                       location: { "projectKey" => "PROJECT_KEY" })
              end

              it { expect(board.project_key).to eq("PROJECT_KEY") }
            end

            context "when location information is not available" do
              it { expect(board.project_key).to eq("N/A") }
            end
          end

          describe "#with_project_information?" do
            context "when location information is available" do
              before do
                allow(jira_board).to receive_messages(location: :a_location)
              end

              it { expect(board).to be_with_project_information }
            end

            context "when location information is not available" do
              it { expect(board).not_to be_with_project_information }
            end
          end
        end
      end
    end
  end
end
