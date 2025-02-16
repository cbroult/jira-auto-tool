# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/team_sprint_ticket_dispatcher"

module Jira
  module Auto
    class Tool
      # rubocop:disable  Metrics/ClassLength, RSpec/MultipleMemoizedHelpers
      class TeamSprintTicketDispatcher
        RSpec.describe TeamSprintTicketDispatcher do
          let(:jira_client) { instance_double(JIRA::Client) }
          let(:ticket_for_1st_team) { build_ticket("Ticket1", "Team1", key: "ART-10040") }
          let(:ticket_for_2nd_team) { build_ticket("Ticket2", "Team2", key: "ART-10041") }
          let(:another_ticket_for_1st_team) { build_ticket("Ticket3", "Team1", key: "ART-10042") }
          let(:another_ticket_for_2nd_team) { build_ticket("Ticket4", "Team2", key: "ART-10043") }
          let(:tickets) do
            [ticket_for_1st_team, ticket_for_2nd_team, another_ticket_for_1st_team, another_ticket_for_2nd_team]
          end
          let(:first_team) { "Team1" }
          let(:second_team) { "Team2" }

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
              described_class.new(jira_client, tickets, sprint_prefixes)
            end

            let(:sprint_prefix_for_1st_team) { build_sprint_prefix("ART_Team1") }
            let(:sprint_prefix_for_2nd_team) { build_sprint_prefix("ART_Team2") }
            let(:sprint_prefixes) { [sprint_prefix_for_1st_team, sprint_prefix_for_2nd_team] }

            describe "#teams" do
              it { expect(dispatcher.teams).to eq(%w[Team1 Team2]) }
            end

            describe "#team_sprint_prefix_mapper" do
              it { expect(dispatcher.team_sprint_prefix_mapper).to be_a(TeamSprintPrefixMapper) }
            end

            describe "#sprint_prefix_for" do
              it { expect(dispatcher.sprint_prefix_for(first_team)).to eq("ART_Team1") }
              it { expect(dispatcher.sprint_prefix_for(second_team)).to eq("ART_Team2") }
              it { expect(dispatcher.sprint_prefix_for("team w/o sprints")).to be_nil }
            end

            describe "#dispatch_tickets" do
              before do
                # allow(team_sprint_prefix_mapper).to receive(:fetch_for).with("Team1").once.and_return("ART_Team1")
                # allow(team_sprint_prefix_mapper).to receive(:fetch_for).with("Team2").once.and_return("ART_Team2")

                allow(ticket_for_1st_team).to receive_messages(key: "ART-10040")
                allow(another_ticket_for_1st_team).to receive_messages(key: "ART-10042")

                allow(ticket_for_2nd_team).to receive_messages(key: "ART-10042")
                allow(another_ticket_for_2nd_team).to receive_messages(key: "ART-10044")

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
              before do
                allow(ticket_for_1st_team).to receive_messages(:sprint= => nil)
                allow(another_ticket_for_1st_team).to receive_messages(:sprint= => nil)
              end

              let(:ticket_planned_after_last_available_sprint) { build_ticket("Ticket5", "Team1") }

              it "updates each ticket with matched sprint" do
                allow(dispatcher).to receive(:match_ticket_to_prefix_sprint)
                  .with(sprint_prefix_for_1st_team, ticket_for_1st_team).and_return(:first_sprint)

                allow(dispatcher).to receive(:match_ticket_to_prefix_sprint)
                  .with(sprint_prefix_for_1st_team, another_ticket_for_1st_team).and_return(:second_sprint)

                dispatcher.dispatch_tickets_to_prefix_sprints("ART_Team1",
                                                              [ticket_for_1st_team,
                                                               another_ticket_for_1st_team])

                expect(ticket_for_1st_team).to have_received(:sprint=).with(:first_sprint)
                expect(another_ticket_for_1st_team).to have_received(:sprint=).with(:second_sprint)
              end

              it "does not update tickets that do not match a sprint" do
                allow(ticket_planned_after_last_available_sprint).to receive_messages(:sprint= => nil)

                allow(dispatcher).to receive(:match_ticket_to_prefix_sprint)
                  .with(sprint_prefix_for_1st_team, ticket_planned_after_last_available_sprint)
                  .and_return(nil)

                dispatcher.dispatch_tickets_to_prefix_sprints("ART_Team1",
                                                              [ticket_planned_after_last_available_sprint])

                expect(ticket_planned_after_last_available_sprint).not_to have_received(:sprint=)
              end
            end
          end

          context "when iterating over tickets" do
            let(:dispatcher) { described_class.new(jira_client, tickets, nil) }

            describe "#per_team_tickets" do
              it "succeeds" do
                expect { |block| dispatcher.per_team_tickets(&block) }
                  .to yield_successive_args(
                    [first_team, [ticket_for_1st_team, another_ticket_for_1st_team]],
                    [second_team, [ticket_for_2nd_team, another_ticket_for_2nd_team]]
                  )
              end
            end
          end

          context "when matching tickets to prefix sprints" do
            let(:dispatcher) { described_class.new(jira_client, nil, nil) }

            describe "#dispatch_to_prefix" do
              RSpec::Matchers.define :be_dispatched_to_sprint do |expected_sprint|
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
                  build_message(expected_sprint, ticket,
                                "but it did not match any sprint or matched an incorrect sprint")
                end

                failure_message_when_negated do |ticket_date|
                  build_message(expected_sprint, ticket_date,
                                "but it matched the expected sprint",
                                "not ")
                end

                def build_message(expected_sprint, ticket, message, condition = "")
                  "expected ticket with start date #{ticket.expected_start_date} #{condition}to dispatch to sprint " \
                  "#{expected_sprint} (name = #{expected_sprint.name}, " \
                  "start date = #{expected_sprint.start_date}), " +
                    message
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
                                    [active_sprint, coming_sprint, next_sprint, last_available_sprint])
              end

              let(:active_sprint) { build_sprint("sprint1", "2025-01-01", "2025-01-04") }
              let(:coming_sprint) { build_sprint("sprint2", "2025-01-04", "2025-01-07") }
              let(:next_sprint) { build_sprint("sprint3", "2025-01-07", "2025-01-10") }
              let(:last_available_sprint) { build_sprint("sprint4", "2025-01-10", "2025-01-13") }

              let(:overdue_ticket) { ticket_due_to_start_on("2024-12-25") }
              let(:ticket_to_start_at_beginning_of_coming_sprint) { ticket_due_to_start_on("2025-01-04") }
              let(:ticket_to_start_at_end_of_coming_sprint) { ticket_due_to_start_on("2025-01-07") }
              let(:ticket_planned_after_last_available_sprint) { ticket_due_to_start_on("2025-01-14") }

              it { expect(overdue_ticket).to be_dispatched_to_sprint(active_sprint) }

              it { expect(ticket_to_start_at_beginning_of_coming_sprint).to be_dispatched_to_sprint(coming_sprint) }

              it { expect(ticket_to_start_at_end_of_coming_sprint).not_to be_dispatched_to_sprint(coming_sprint) }
              it { expect(ticket_to_start_at_end_of_coming_sprint).to be_dispatched_to_sprint(next_sprint) }

              it do
                expect(ticket_planned_after_last_available_sprint)
                  .not_to be_dispatched_to_sprint(last_available_sprint)
              end

              it "does not match a ticket planned after the last sprint" do
                expect(dispatcher.match_ticket_to_prefix_sprint(
                         sprint_prefix, ticket_planned_after_last_available_sprint
                       ))
                  .to be_nil
              end
            end
          end
        end
      end

      # rubocop:enable  Metrics/ClassLength, RSpec/MultipleMemoizedHelpers
    end
  end
end
