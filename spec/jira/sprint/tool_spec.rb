# frozen_string_literal: true

require "jira/sprint/tool"
module Jira
  module Sprint
    RSpec.describe Jira::Sprint::Tool do
      before do
        @tool = described_class.new
      end

      it "has a version number" do
        expect(Jira::Sprint::Tool::VERSION).not_to be_nil
      end

      describe "#board" do
        def board_double(name)
          double("Board", name: name) # rubocop:disable RSpec/VerifiedDoubles
        end

        let(:expected_board) { board_double("a board name") }

        let(:boards) do
          other_boards = 0.upto(10).collect { |i| board_double("board_#{i}") }
          other_boards << expected_board
          other_boards.shuffle
        end

        it "has a board" do
          allow(@tool).to receive_messages(board_name: "a board name")
          allow(@tool).to receive_messages(boards: boards)

          expect(@tool.board).to equal(expected_board)
        end
      end

      describe "#create_sprints" do
        it "creates sprints" do
          allow(@tool).to receive_messages(create_future_sprint: nil, transition_sprint_state: nil)

          @tool.create_sprint(name: "sprint_name", start: "2024-12-16 11:00 UTC", length_in_days: 14, goal: "a goal",
                              state: "a state")

          expect(@tool).to have_received(:create_future_sprint).with("sprint_name",
                                                                     "2024-12-16 11:00 UTC", 14, "a goal")
          expect(@tool).to have_received(:transition_sprint_state).with(name: "sprint_name", desired_state: "a state")
        end
      end

      describe "#create_future_sprint" do
        let(:jira_client) { instance_spy(JIRA::Client) }

        let(:expected_response) do
          instance_double(Net::HTTPResponse, code: 201, body: "sprint created successfully")
        end

        let(:board) { instance_spy(JIRA::Resource::Board, id: 16) }

        it do
          allow(@tool).to receive_messages(jira_client: jira_client, board: board)
          allow(jira_client).to receive_messages(post: expected_response)

          @tool.send(:create_future_sprint, "sprint_name", "2024-12-16 11:00 UTC", 14, "a goal")

          expect(jira_client).to have_received(:post)
            .with(
              "/rest/agile/1.0/sprint",
              {
                originBoardId: 16,
                name: "sprint_name",
                startDate: "2024-12-16T11:00:00Z",
                endDate: "2024-12-30T11:00:00Z",
                goal: "a goal"
              }.to_json,
              { "Content-Type" => "application/json" }
            )
        end
      end

      describe "#fetch_sprint" do
        def build_sprint(name)
          double(JIRA::Resource::Sprint, name: name) # rubocop:disable RSpec/VerifiedDoubles
        end

        let(:expected_sprint) { build_sprint("expected_sprint_name") }

        let(:board_sprints) do
          other_boards = 4.times.to_a.collect { |i| build_sprint("sprint_#{i}") }
          other_boards << expected_sprint
          other_boards.shuffle
        end

        let(:board) { instance_double(JIRA::Resource::Board, sprints: board_sprints) }

        it do
          allow(@tool).to receive_messages(board: board)

          expect(@tool.fetch_sprint("expected_sprint_name")).to be(expected_sprint)
        end
      end

      describe "#update_sprint_state" do
        let(:sprint_to_update) do
          instance_spy(JIRA::Resource::Sprint, id: 12_345, attrs: { id: 12_345, state: "open" })
        end

        let(:jira_client) do
          jira_client = instance_spy(JIRA::Client).as_null_object
          allow(JIRA::Client).to receive_messages(new: jira_client)
          jira_client
        end

        let(:expected_response) do
          instance_double(Net::HTTPResponse, code: 200, body: "sprint updated successfully")
        end

        let(:expected_payload) do
          {
            "id" => 12_345,
            "self" => nil,
            "name" => nil,
            "startDate" => nil,
            "endDate" => nil,
            "originBoardId" => nil,
            "state" => "closed"
          }
        end

        let(:expected_put_args) do
          [
            "/rest/agile/1.0/sprint/12345",
            expected_payload.to_json,
            { "Content-Type" => "application/json" }
          ]
        end

        it "updates a sprint" do
          allow(@tool).to receive_messages(fetch_sprint: sprint_to_update)
          allow(jira_client).to receive_messages(put: expected_response)

          @tool.send(:update_sprint_state, sprint: sprint_to_update, new_state: "closed")

          expect(jira_client).to have_received(:put).with(*expected_put_args)
        end
      end

      it "#sprint_controller" do
        expect(@tool.sprint_controller).not_to be_nil
      end

      it "#sprint_generator" do
        expect(@tool.sprint_generator).not_to be_nil
      end

      RSpec.shared_examples "an environment based value" do |method_name|
        let(:env_var_name) { method_name.to_s.upcase }

        it "fetch its value from the environment" do
          expected_value = "#{env_var_name} env_value"
          allow(ENV).to receive(:fetch).with(env_var_name).and_return(expected_value)

          expect(@tool.send(method_name)).to eq(expected_value)
        end

        it "raises an error if the environment variable is not found" do
          allow(ENV).to receive(:fetch).with(env_var_name)
                                       .and_raise(KeyError.new("Missing #{env_var_name} environment variable!)"))

          expect { @tool.send(method_name) }.to raise_error(KeyError, /Missing #{env_var_name} environment variable!/)
        end
      end

      describe "jira_board_name" do
        it_behaves_like "an environment based value", :jira_board_name

        it "can be overridden explicitly" do
          @tool.jira_board_name = "a board name"

          expect(@tool.jira_board_name).to eq("a board name")
        end
      end

      %i[jira_api_token jira_site_url jira_username].each do |method_name|
        describe method_name.to_s do
          it_behaves_like "an environment based value", method_name
        end
      end

      describe "#jira_client" do
        let(:client_options) do
          {
            username: "jira_username_value",
            password: "jira_api_token_value",
            site: "jira_site_url_value",
            context_path: "",
            auth_type: :basic
          }
        end

        it "has a jira client" do
          allow(@tool).to receive_messages(jira_username: "jira_username_value", jira_site_url: "jira_site_url_value",
                                           jira_api_token: "jira_api_token_value")

          expected_jira_client = instance_double(JIRA::Client)

          allow(JIRA::Client).to receive(:new).with(client_options).and_return(expected_jira_client)

          expect(@tool.jira_client).to equal(expected_jira_client)
        end
      end
    end
  end
end
