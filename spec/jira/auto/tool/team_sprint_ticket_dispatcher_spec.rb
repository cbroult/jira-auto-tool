# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/team_sprint_ticket_dispatcher"

module Jira
  module Auto
    class Tool
      # rubocop:disable  Metrics/ClassLength
      # rubocop:disable  RSpec/MultipleMemoizedHelpers
      class TeamSprintTicketDispatcher
        RSpec.describe TeamSprintTicketDispatcher do
          let(:jira_client) { instance_double(JIRA::Client) }
          let(:team_sprint_prefix_mapper) do
            instance_double(TeamSprintPrefixMapper,
                            team_sprint_prefix_mappings: { "Team1" => "ART_Team1", "Team2" => "ART_Team2" })
          end
          let(:ticket_for_1st_team) { build_ticket("Ticket1", "Team1") }
          let(:ticket_for_2nd_team) { build_ticket("Ticket2", "Team2") }
          let(:another_ticket_for_1st_team) { build_ticket("Ticket3", "Team1") }
          let(:another_ticket_for_2nd_team) { build_ticket("Ticket4", "Team2") }
          let(:tickets) do
            [ticket_for_1st_team, ticket_for_2nd_team, another_ticket_for_1st_team, another_ticket_for_2nd_team]
          end
          let(:teams) { %w[Team1 Team2] }

          def build_ticket(summary, implementation_team, expected_start_date = "undefined")
            instance_double(Ticket,
                            summary: summary,
                            implementation_team: implementation_team,
                            expected_start_date: expected_start_date)
          end

          def build_sprint_prefix(name, sprints = [])
            instance_double(Sprint::Prefix, name: name, sprints: sprints)
          end

          context "when dispatching tickets" do
            let(:dispatcher) do
              described_class.new(jira_client, teams, tickets, sprint_prefixes, team_sprint_prefix_mapper)
            end

            let(:sprint_prefix_for_1st_team) { build_sprint_prefix("ART_Team1") }
            let(:sprint_prefix_for_2nd_team) { build_sprint_prefix("ART_Team2") }
            let(:sprint_prefixes) { [sprint_prefix_for_1st_team, sprint_prefix_for_2nd_team] }

            describe "#dispatch_tickets" do
              before do
                allow(team_sprint_prefix_mapper).to receive(:fetch_for).with("Team1").once.and_return("ART_Team1")
                allow(team_sprint_prefix_mapper).to receive(:fetch_for).with("Team2").once.and_return("ART_Team2")

                allow(dispatcher).to receive_messages(dispatch_tickets_to_prefix_sprints: nil)
              end

              it "dispatches 1st team tickets to the expected prefix" do
                dispatcher.dispatch_tickets

                expect(dispatcher)
                  .to have_received(:dispatch_tickets_to_prefix_sprints).with("ART_Team1",
                                                                              [ticket_for_1st_team,
                                                                               another_ticket_for_1st_team]).once
              end

              it "dispatches 2nd team tickets to the expected prefix" do
                dispatcher.dispatch_tickets

                expect(dispatcher)
                  .to have_received(:dispatch_tickets_to_prefix_sprints).with("ART_Team2",
                                                                              [ticket_for_2nd_team,
                                                                               another_ticket_for_2nd_team]).once
              end
            end

            describe "#dispatch_tickets_to_prefix_sprints" do
              it "dispatches tickets to the expected sprints" do
                allow(dispatcher).to receive_messages(match_ticket_to_prefix_sprint: nil)
                allow(ticket_for_1st_team).to receive_messages(:sprint= => nil)
                allow(another_ticket_for_1st_team).to receive_messages(:sprint= => nil)

                dispatcher.dispatch_tickets_to_prefix_sprints("ART_Team1", [ticket_for_1st_team, another_ticket_for_1st_team])

                expect(dispatcher).
                  to have_received(:match_ticket_to_prefix_sprint).
                    with(sprint_prefix_for_1st_team, ticket_for_1st_team)

                expect(ticket_for_1st_team).to have_received(:sprint=).with(sprint_prefix_for_1st_team)

                expect(dispatcher).
                  to have_received(:match_ticket_to_prefix_sprint).
                    with(sprint_prefix_for_1st_team, another_ticket_for_1st_team)

                expect(another_ticket_for_1st_team).to have_received(:sprint=).with(sprint_prefix_for_1st_team)
              end
            end
          end

          context "when iterating over tickets" do
            let(:dispatcher) { described_class.new(jira_client, teams, tickets, nil, team_sprint_prefix_mapper) }

            describe "#per_team_tickets" do
              it "succeeds" do
                expect { |block| dispatcher.per_team_tickets(&block) }
                  .to yield_successive_args(
                    ["Team1", [ticket_for_1st_team, another_ticket_for_1st_team]],
                    ["Team2", [ticket_for_2nd_team, another_ticket_for_2nd_team]]
                  )
              end
            end

            describe "#sprint_prefix_for" do
              it {
                allow(team_sprint_prefix_mapper).to receive_messages(fetch_for: "ART_Team1")

                expect(dispatcher.sprint_prefix_for("Team1")).to eq("ART_Team1")
              }

              it {
                allow(team_sprint_prefix_mapper).to receive_messages(fetch_for: "ART_Team2")

                expect(dispatcher.sprint_prefix_for("Team2")).to eq("ART_Team2")
              }
            end
          end

          context "when matching tickets to prefix sprints" do
            let(:dispatcher) { described_class.new(jira_client, nil, nil, nil, nil) }

            describe "#dispatch_to_prefix" do
              RSpec::Matchers.define :dispatch_to_sprint do |expected_sprint|
                match do |ticket|
                  matched_sprint = dispatcher.match_ticket_to_prefix_sprint(sprint_prefix, ticket)

                  log.debug do
                    <<-EOMATCHINFO
                    ticket: #{ticket.expected_start_date}
                    matched sprint: #{matched_sprint&.name} #{matched_sprint&.start_date}" }
                    expected sprint: #{expected_sprint&.name} #{expected_sprint&.start_date}"
                    EOMATCHINFO
                  end

                  matched_sprint && matched_sprint.name == expected_sprint.name
                end

                failure_message do |ticket|
                  "expected ticket with start date #{ticket.expected_start_date} to dispatch to sprint " \
                    "#{expected_sprint} (name = #{expected_sprint.name}, " \
                    "start date = #{expected_sprint.start_date}), " \
                    "but it did not match any sprint or matched an incorrect sprint"
                end

                failure_message_when_negated do |ticket_date|
                  "expected ticket with start date #{ticket_date.expected_start_date} not to dispatch " \
                    "to sprint #{expected_sprint}, but it was dispatched"
                end
              end

              def build_sprint(name, start_date, end_date)
                instance_double(Sprint,
                                name: name,
                                start_date: Time.parse(start_date),
                                end_date: Time.parse(end_date))
              end

              def ticket_due_to_start_on(start_date)
                build_ticket("ticket_name for #{start_date}", "Team1", start_date)
              end

              let(:sprint_prefix) do
                build_sprint_prefix("a sprint prefix",
                                    [earliest_sprint, second_sprint, third_sprint, last_available_sprint])
              end

              let(:earliest_sprint) { build_sprint("sprint1", "2025-01-01", "2025-01-04") }
              let(:second_sprint) { build_sprint("sprint2", "2025-01-04", "2025-01-07") }
              let(:third_sprint) { build_sprint("sprint3", "2025-01-07", "2025-01-10") }
              let(:last_available_sprint) { build_sprint("sprint4", "2025-01-10", "2025-01-13") }

              it "matches an overdue ticket with the first sprint" do
                expect(ticket_due_to_start_on("2024-12-25")).to dispatch_to_sprint(earliest_sprint)
              end

              it { expect(ticket_due_to_start_on("2025-01-04")).to dispatch_to_sprint(second_sprint) }
              it { expect(ticket_due_to_start_on("2025-01-07")).not_to dispatch_to_sprint(second_sprint) }
              it { expect(ticket_due_to_start_on("2025-01-07")).to dispatch_to_sprint(third_sprint) }

              it {
                expect(ticket_due_to_start_on("2025-01-14"))
                  .not_to dispatch_to_sprint(last_available_sprint)
              }

              it "does not match a ticket planned after the last sprint" do
                expect(dispatcher.match_ticket_to_prefix_sprint(
                         sprint_prefix, ticket_due_to_start_on("2025-01-14")
                       ))
                  .to be_nil
              end
            end
          end
        end
      end

      # rubocop:enable  RSpec/MultipleMemoizedHelpers
      # rubocop:enable  Metrics/ClassLength RSpec/MultipleMemoizedHelpers
    end
  end
end
