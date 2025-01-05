# frozen_string_literal: true

require "jira/auto/tool"

module Jira
  module Auto
    # rubocop:disable  Metrics/ClassLength
    class Tool
      RSpec.describe Tool do
        let(:tool) { described_class.new }

        it "has a version number" do
          expect(Jira::Auto::Tool::VERSION).not_to be_nil
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
            allow(tool).to receive_messages(board_name: "a board name")
            allow(tool).to receive_messages(boards: boards)

            expect(tool.board).to equal(expected_board)
          end
        end

        describe "#create_sprint" do
          # rubocop:disable RSpec/MultipleExpectations
          it "creates a future auto and transitions it to the desired state" do
            allow(tool).to receive_messages(create_future_sprint: nil, transition_sprint_state: nil)

            tool.create_sprint(name: "sprint_name_24.4.2", start: "2024-12-16 11:00 UTC", length_in_days: 14,
                               state: "a state")

            expect(tool).to have_received(:create_future_sprint).with("sprint_name_24.4.2",
                                                                      "2024-12-16 11:00 UTC", 14)
            expect(tool).to have_received(:transition_sprint_state).with(name: "sprint_name_24.4.2",
                                                                         desired_state: "a state")
          end
          # rubocop:enable RSpec/MultipleExpectations
        end

        describe "#fetch_sprint" do
          def build_sprint(name)
            instance_double(Sprint, name: name)
          end

          let(:expected_sprint) { build_sprint("expected_sprint_name_24.4.1") }

          let(:board_sprints) do
            other_boards = 4.times.to_a.collect { |i| build_sprint("sprint_#{i}") }
            other_boards << expected_sprint
            other_boards.shuffle
          end

          let(:actual_sprint_controller) { instance_double(SprintController, sprints: board_sprints) }

          it do
            allow(tool).to receive_messages(sprint_controller: actual_sprint_controller)

            expect(tool.fetch_sprint("expected_sprint_name_24.4.1")).to eq(expected_sprint)
          end
        end

        it "#sprint_controller" do
          expect(tool.sprint_controller).not_to be_nil
        end

        describe "#project" do
          before do
            allow(tool)
              .to receive_messages(
                board:
                  jira_resource_double(JIRA::Resource::Board, project: { "key" => "project_key" }),
                jira_client:
                  jira_resource_double(
                    JIRA::Client,
                    Project: jira_resource_double(
                      "Project",
                      all: [jira_resource_double(
                        JIRA::Resource::Project,
                        key: "project_key"
                      )]
                    )
                  )
              )
          end

          it { expect(tool.project.key).to eq("project_key") }
        end

        RSpec.shared_examples "an overridable environment based value" do |method_name|
          let(:env_var_name) { method_name.to_s.upcase }

          it "fetch its value from the environment" do
            expected_value = "#{env_var_name} env_value"
            allow(ENV).to receive(:fetch).with(env_var_name).and_return(expected_value)

            expect(object_with_overridable_value.send(method_name)).to eq(expected_value)
          end

          it "raises an error if the environment variable is not found" do
            allow(ENV).to receive(:fetch)
              .with(env_var_name)
              .and_raise(KeyError.new("Missing #{env_var_name} environment variable!)"))

            expect { object_with_overridable_value.send(method_name) }
              .to raise_error(KeyError, /Missing #{env_var_name} environment variable!/)
          end

          it "can be overridden explicitly" do
            override_value = "override value for #{method_name}"
            object_with_overridable_value.send("#{method_name}=", override_value)

            expect(object_with_overridable_value.send(method_name)).to eq(override_value)
          end
        end

        %i[
          expected_start_date_field_name
          implementation_team_field_name
          jira_api_token
          jira_board_name
          jira_site_url jira_username
          jira_sprint_field_name
        ].each do |method_name|
          describe "environment based values" do
            let(:object_with_overridable_value) { tool }

            it_behaves_like "an overridable environment based value", method_name
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
            allow(tool).to receive_messages(jira_username: "jira_username_value", jira_site_url: "jira_site_url_value",
                                            jira_api_token: "jira_api_token_value")

            expected_jira_client = instance_double(JIRA::Client)

            allow(JIRA::Client).to receive(:new).with(client_options).and_return(expected_jira_client)

            expect(tool.jira_client).to equal(expected_jira_client)
          end
        end

        context "when dealing with ticket fields" do
          let(:ticket_field) { instance_double(JIRA::Resource::Field) }

          describe "#project_ticket_fields" do
            it { expect(tool.project_ticket_fields).not_to be_empty }
          end

          describe "#expected_start_date_field" do
            let(:field_controller) { instance_double(FieldController, expected_start_date_field: ticket_field) }

            it do
              allow(tool).to receive_messages(field_controller: field_controller)

              expect(tool.expected_start_date_field("start_date_field")).not_to be_nil
            end
          end

          describe "#implementation_team_field" do
            let(:field_controller) { instance_double(FieldController, implementation_team_field: ticket_field) }

            it do
              allow(tool).to receive_messages(field_controller: field_controller)

              expect(tool.implementation_team_field("team_field")).not_to be_nil
            end
          end
        end

        context "when dealing with sprints" do
          let(:expected_sprint_prefixes) { [instance_double(Sprint::Prefix)] }

          let(:sprint_controller) do
            instance_double(SprintController,
                            unclosed_sprints: ["a sprint", "another sprint"],
                            unclosed_sprint_prefixes: expected_sprint_prefixes)
          end

          before do
            allow(tool).to receive_messages(sprint_controller: sprint_controller)
          end

          describe "#unclosed_sprints" do
            it do
              expect(tool.unclosed_sprints).to eq(["a sprint", "another sprint"])
            end
          end

          describe "#unclosed_sprint_prefixes" do
            it "returns an array of sprint prefixes" do
              expect(tool.unclosed_sprint_prefixes).to eq(expected_sprint_prefixes)
            end
          end
        end

        context "when dealing with mapping team tickets to sprints" do
          describe "#team_sprint_ticket_dispatcher" do
            before do
              allow(tool).to receive_messages(jira_client: nil, teams: nil, tickets: nil,
                                              unclosed_sprint_prefixes: nil, team_sprint_prefix_mapper: nil)
            end

            it { expect(tool.team_sprint_ticket_dispatcher).to be_a(TeamSprintTicketDispatcher) }
          end

          describe "#team_sprint_prefix_mapper" do
            before do
              allow(tool).to receive_messages(teams: [instance_double(Team)],
                                              unclosed_sprint_prefixes: [instance_double(Sprint::Prefix)])
            end

            it { expect(tool.team_sprint_prefix_mapper).to be_a(TeamSprintPrefixMapper) }
          end

          describe "#tickets" do
            it { expect(tool.tickets).to all be_a(Ticket) }
          end

          describe "#teams" do
            let(:team_field_options) do
              ["a team", "another team", "a third team"].collect do |team_name|
                instance_double(FieldOption, value: team_name)
              end
            end

            let(:team_field) { instance_double(Field, values: team_field_options) }

            it do
              allow(tool).to receive_messages(implementation_team_field: team_field)

              expect(tool.teams).to all be_a(Team)
            end
          end
        end
      end
    end

    # rubocop:enable  Metrics/ClassLength
  end
end
