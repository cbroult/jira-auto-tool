# frozen_string_literal: true

require "jira/auto/tool"

module Jira
  module Auto
    # rubocop:disable  Metrics/ClassLength
    class Tool
      RSpec.describe Tool do
        let(:tool) { described_class.new }

        before { allow(EnvironmentLoader).to receive_messages(new: instance_double(EnvironmentLoader)) }

        it "has a version number" do
          expect(Jira::Auto::Tool::VERSION).not_to be_nil
        end

        describe "#board_controller" do
          before { allow(tool).to receive_messages(jira_client: instance_double(RateLimitedJiraClient)) }

          it { expect(tool.board_controller).to be_a(BoardController) }
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

        describe "#environment" do
          let(:environment_loader) { instance_double(EnvironmentLoader) }

          before { allow(EnvironmentLoader).to receive_messages(new: environment_loader) }

          it { expect(tool.environment).to eq(environment_loader) }
        end

        # rubocop:disable RSpec/StubbedMock
        describe "#create_sprint" do
          it "creates a future sprint and transitions it to the desired state" do
            expect(tool).to receive(:transition_sprint_state).with(:created_sprint, desired_state: "a state")

            expect(tool).to receive(:create_future_sprint)
              .with({ name: "sprint_name_24.4.2", start_date: "2024-12-16 11:00 UTC",
                      length_in_days: 14 })
              .and_return(:created_sprint)

            tool.create_sprint({ name: "sprint_name_24.4.2", start_date: "2024-12-16 11:00 UTC", length_in_days: 14,
                                 state: "a state" })
          end

          context "when specifying end_date" do
            it "overrides the length_in_days" do
              expect(tool).to receive(:transition_sprint_state).with(:created_sprint, desired_state: "a state")

              expect(tool).to receive(:create_future_sprint)
                .with({ name: "sprint_name_24.4.2", start_date: "2024-12-16 11:00 UTC",
                        end_date: "2024-12-23 11:00 UTC" })
                .and_return(:created_sprint)

              tool.create_sprint({ name: "sprint_name_24.4.2", start_date: "2024-12-16 11:00 UTC",
                                   end_date: "2024-12-23 11:00 UTC",
                                   state: "a state" })
            end
          end
        end
        # rubocop:enable RSpec/StubbedMock

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

        describe "#sprint_controller" do
          let(:board) { instance_double(Board, project_key: "board_project_key") }

          before do
            allow(tool).to receive_messages(board: board)
          end

          it { expect(tool.sprint_controller).to be_a(SprintController) }
        end

        describe "#home_dir" do
          it { expect(tool.home_dir).to eq(File.expand_path("../../../", __dir__)) }
        end

        describe "#project" do
          let(:jira_client) { instance_double(RateLimitedJiraClient, Project: project_query) }
          let(:jira_project) { instance_double(JIRA::Resource::Project) }
          let(:jira_project_key) { "JIRA_PROJECT_KEY" }
          let(:project_query) { double("project_query", find: jira_project) } # rubocop:disable RSpec/VerifiedDoubles

          before do
            allow(tool).to receive_messages(jira_project_key: jira_project_key, jira_client: jira_client)
          end

          it { expect(tool.project).to be_a(Project) }
        end

        # TODO: move that to environment_based_value_spec
        RSpec.shared_examples "an overridable environment based value" do |method_name|
          let(:env_var_name) { method_name.to_s.upcase }
          let(:method_name?) { :"#{method_name}_defined?" }
          let(:config) { Config.new(object_with_overridable_value) }

          before do
            allow(object_with_overridable_value).to receive_messages(config: config)
            allow(config).to receive_messages(value_store: {})
          end

          context "when the environment variable is set" do
            let(:expected_value) { "#{env_var_name} env_value" }

            before do
              allow(ENV).to receive(:fetch).with(env_var_name).and_return(expected_value)
              allow(ENV).to receive(:key?).with(env_var_name).and_return(true)
            end

            it("method_name?") { expect(object_with_overridable_value.send(method_name?)).to be(true) }

            it("method_name_when_defined_else") do
              expect(object_with_overridable_value.send("#{method_name}_when_defined_else", "DEFAULT_VALUE"))
                .to eq(expected_value)
            end

            it "fetches its value from the environment" do
              expect(object_with_overridable_value.send(method_name)).to eq(expected_value)
            end

            # TODO: do the following also in case the env var is not defined
            context "when the value is defined in the configuration" do
              let(:expected_config_value) { "<<<<#{method_name} config value>>>>" }

              before { allow(config).to receive_messages(value_store: { method_name.to_s => expected_config_value }) }

              it "uses the configured value" do
                expect(object_with_overridable_value.send("#{method_name}_when_defined_else", "DEFAULT_VALUE"))
                  .to eq(expected_config_value)
              end
            end
          end

          context "when the environment variable is not set" do
            before do
              allow(ENV).to receive(:fetch)
                .with(env_var_name)
                .and_raise(KeyError.new("Missing #{env_var_name} environment variable!)"))

              allow(ENV).to receive(:key?).with(env_var_name).and_return(false)
            end

            it("method_name?") { expect(object_with_overridable_value.send(method_name?)).to be(false) }

            it("method_name_when_defined_else") do
              expect(object_with_overridable_value.send("#{method_name}_when_defined_else", "DEFAULT_VALUE"))
                .to eq("DEFAULT_VALUE")
            end

            it "raises an error if the environment variable is not found" do
              expect { object_with_overridable_value.send(method_name) }
                .to raise_error(KeyError, /Missing #{env_var_name} environment variable!/)
            end
          end

          it "can be overridden explicitly and updates the config" do
            override_value = "override value for #{method_name}"

            config = instance_double(Config)
            allow(config).to receive_messages(:[]= => nil, :key? => true, :[] => override_value)
            allow(object_with_overridable_value).to receive_messages(config: config)

            object_with_overridable_value.send("#{method_name}=", override_value)

            expect(object_with_overridable_value.send(method_name)).to eq(override_value)
            expect(config).to have_received(:[]=).with(method_name, override_value)
          end

          it "defines an Environment constant with the same name" do
            const_name = method_name.to_s.upcase
            fully_qualified_const_name = "#{described_class}::Environment::#{const_name}"

            expect(described_class.const_defined?(fully_qualified_const_name)).to be true
            expect(described_class.const_get(fully_qualified_const_name)).to eq(const_name)
          end
        end

        %i[
          expected_start_date_field_name
          implementation_team_field_name
          jat_tickets_for_team_sprint_ticket_dispatcher_jql
          jat_rate_limit_in_seconds
          jat_rate_interval_in_seconds
          jira_api_token
          jira_board_name
          jira_board_name_regex
          jira_context_path
          jira_http_debug
          jira_project_key
          jira_site_url jira_username
          jira_sprint_field_name
        ].each do |method_name|
          describe "environment based values" do
            let(:object_with_overridable_value) { tool }

            it_behaves_like "an overridable environment based value", method_name
          end
        end

        context "when dealing with jira site and context path related values" do
          let(:jira_client) do
            JIRA::Client.new({ site: "https://jira_site_url_value", context_path: "/context_path_value" })
          end

          before do
            allow(tool).to receive_messages(jira_client: jira_client)
          end

          describe "#jira_base_url" do
            it { expect(tool.jira_base_url).to eq("https://jira_site_url_value/context_path_value") }
          end

          describe "#jira_request_path" do
            it { expect(tool.jira_request_path("/some/path")).to eq("/context_path_value/some/path") }
          end

          describe "#jira_url" do
            before { allow(tool).to receive_messages(jira_base_url: "https://jira_site_url_value/context_path_value") }

            it "has a jira instance url" do
              expect(tool.jira_url("/board/4")).to eq("https://jira_site_url_value/context_path_value/board/4")
            end
          end
        end

        describe "#jira_client" do
          let(:client_options) do
            {
              username: "jira_username_value",
              password: "jira_api_token_value",
              site: "https://jira_site_url_value",
              context_path: "/context_path_value",
              auth_type: :basic,
              http_debug: false
            }
          end

          before do
            allow(tool)
              .to receive_messages(jira_username: "jira_username_value", jira_site_url: "https://jira_site_url_value",
                                   jira_api_token: "jira_api_token_value",
                                   jira_context_path_when_defined_else: "/context_path_value",
                                   jira_http_debug?: false,
                                   jat_rate_limit_in_seconds_when_defined_else: "10",
                                   jat_rate_interval_in_seconds_when_defined_else: "60")
          end

          it "has a jira client" do
            expected_jira_client = instance_double(RateLimitedJiraClient)

            allow(RateLimitedJiraClient)
              .to receive(:new).with(client_options, rate_limit: 10, rate_interval: 60)
                               .and_return(expected_jira_client)

            expect(tool.jira_client).to equal(expected_jira_client)
          end
        end

        # TODO: overly complex - simplify
        describe "#jira_http_debug?" do
          let(:jira_http_debug_defined?) { true }
          let(:config) { Config.new(tool) }

          before do
            allow(tool).to receive_messages(config: config)
          end

          context "when jira_http_debug is overridden with a specific value" do
            it "can be overridden explicitly and updates the config" do
              tool.jira_http_debug = true

              expect(tool).to be_jira_http_debug
            end

            it "can be set to false" do
              tool.jira_http_debug = false

              expect(tool).not_to be_jira_http_debug
            end
          end

          context "when jira_http_debug has not been overridden with a specific value" do
            before do
              allow(tool).to receive_messages(jira_http_debug: jira_http_debug,
                                              jira_http_debug_defined?: jira_http_debug_defined?)
              allow(config).to receive_messages(value_store: {})
            end

            context "when a true value is set for jira_http_debug" do
              let(:jira_http_debug) { "true" }

              it { expect(tool).to be_jira_http_debug }
            end

            context "when jira_http_debug is set to nil" do
              let(:jira_http_debug) { nil }

              it { expect(tool).not_to be_jira_http_debug }
            end

            context "when a false value is set for jira_http_debug" do
              let(:jira_http_debug) { "false" }

              it { expect(tool).not_to be_jira_http_debug }
            end
          end
        end

        context "when dealing with ticket fields" do
          let(:ticket_field) { instance_double(JIRA::Resource::Field) }

          describe "#project_ticket_fields" do
            let(:project) { instance_double(Project, ticket_fields: [ticket_field]) }

            before do
              allow(tool).to receive_messages(project: project)
            end

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
              allow(tool).to receive_messages(jira_client: nil,
                                              unclosed_sprint_prefixes: nil,
                                              jat_tickets_for_team_sprint_ticket_dispatcher_jql: :jql_for_tickets)

              allow(tool).to receive(:tickets).with(:jql_for_tickets)
                                              .and_return([instance_double(JIRA::Resource::Issue)])
            end

            it { expect(tool.team_sprint_ticket_dispatcher).to be_a(TeamSprintTicketDispatcher) }
          end

          describe "#tickets" do
            let(:query) { jira_resource_double("query") }
            let(:jira_client) { instance_double(RateLimitedJiraClient, Issue: query) }

            before do
              allow(tool).to receive_messages(jira_client: jira_client)

              allow(tool)
                .to receive_messages(project: jira_resource_double(JIRA::Resource::Project, key: "project_key"))

              allow(query).to receive(:jql).with(expected_jql).and_return([instance_double(JIRA::Resource::Issue)])
            end

            context "without arguments" do
              let(:expected_jql) { "project = project_key" }

              it { expect(tool.tickets).to all be_a(Ticket) }
            end

            context "with a jql" do
              let(:expected_jql) { "a jql" }

              it { expect(tool.tickets(expected_jql)).to all be_a(Ticket) }
            end
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

              expect(tool.teams).to eq(["a team", "another team", "a third team"])
            end
          end
        end
      end
    end

    # rubocop:enable  Metrics/ClassLength
  end
end
