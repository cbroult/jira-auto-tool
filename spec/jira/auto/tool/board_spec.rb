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

          describe "#<=>" do
            def new_board(id)
              described_class.new(tool, instance_double(JIRA::Resource::Board, id: id))
            end

            let(:board_with_same_id) { new_board(4) }

            it { expect(board <=> board_with_same_id).to eq(0) }
            it { expect(new_board(1) <=> board).to eq(-1) }
            it { expect(new_board(5) <=> board).to eq(1) }
          end

          describe ".find_by_id" do
            before do
              allow(JIRA::Resource::Board).to receive(:find).with(jira_client, 4).and_return(jira_board)
            end

            it { expect(described_class.find_by_id(tool, 4)).to eq(board) }
          end

          describe ".to_table_row_field_names" do
            it { expect(described_class.to_table_row_field_names).to eq(%i[name ui_url project_key]) }
          end

          describe ".to_table_row_header" do
            it { expect(described_class.to_table_row_header).to eq(["Name", "UI URL", "Project Key"]) }
          end

          describe "#to_table_row" do
            before do
              allow(board).to receive_messages(project_key: "PROJECT_KEY", ui_url: "UI_URL")
            end

            it { expect(board.to_table_row).to eq(["board name", "UI_URL", "PROJECT_KEY"]) }
          end

          describe "#sprint_compatible?" do
            context "when a scrum board" do
              let(:jira_board) { jira_resource_double(JIRA::Resource::Board, type: "scrum") }

              it { expect(board).to be_sprint_compatible }
            end

            context "when sprints are not available" do
              let(:jira_board) { jira_resource_double(JIRA::Resource::Board, type: "non scrum") }

              it { expect(board).not_to be_sprint_compatible }
            end
          end

          describe "#ui_url" do
            context "when location information is not available" do
              before do
                allow(board).to receive_messages(with_project_information?: false)

                allow(tool).to receive(:jira_url)
                  .with("/secure/RapidBoard.jspa?rapidView=4")
                  .and_return("https://a-jira-site.example.com/jira/secure/RapidBoard.jspa?rapidView=4")
              end

              it do
                expect(board.ui_url)
                  .to eq("https://a-jira-site.example.com/jira/secure/RapidBoard.jspa?rapidView=4")
              end
            end

            context "when location information is available" do
              # TODO: - fix the URL
              before do
                allow(board).to receive_messages(with_project_information?: true, project_key: "PROJECT_KEY")

                allow(tool)
                  .to receive(:jira_url)
                  .with("/jira/software/c/projects/PROJECT_KEY/boards/4")
                  .and_return("https://a-jira-site.example.com/jira/software/c/projects/PROJECT_KEY/boards/4")
              end

              it do
                expect(board.ui_url)
                  .to eq("https://a-jira-site.example.com/jira/software/c/projects/PROJECT_KEY/boards/4")
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
