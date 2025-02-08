# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/performer/sprint_time_in_dates_aligner"

module Jira
  module Auto
    class Tool
      class Performer
        class SprintTimeInDatesAligner
          RSpec.describe SprintTimeInDatesAligner do
            let(:sprint_in_dates_aligner) { described_class.new(tool, "12:31 +0100") }
            let(:tool) { instance_double(Tool) }

            describe "#run" do
              it do
                allow(sprint_in_dates_aligner).to receive_messages(update_sprint_dates_with_expected_time: nil)

                sprint_in_dates_aligner.run

                expect(sprint_in_dates_aligner).to have_received(:update_sprint_dates_with_expected_time)
              end
            end

            describe "#update_sprint_dates_with_expected_time" do
              let(:unclosed_sprints) { %i[a_sprint another_sprint] }

              it "updates unclosed sprints" do
                allow(tool).to receive_messages(unclosed_sprints: unclosed_sprints)
                allow(sprint_in_dates_aligner).to receive_messages(update_sprint_dates_for: nil)

                sprint_in_dates_aligner.update_sprint_dates_with_expected_time

                expect(sprint_in_dates_aligner).to have_received(:update_sprint_dates_for).once.with(:a_sprint)
                expect(sprint_in_dates_aligner).to have_received(:update_sprint_dates_for).once.with(:another_sprint)
              end
            end

            describe "#sprint_time_in_dates" do
              it { expect(sprint_in_dates_aligner.sprint_time_in_dates).to be_a(Time) }
            end

            describe("#update_sprint_dates_for") do
              context "when sprint is closed" do
                let(:sprint) do
                  instance_double(Sprint, closed?: true, save: nil)
                end

                it do
                  sprint_in_dates_aligner.update_sprint_dates_for(sprint)

                  expect(sprint).not_to have_received(:save)
                end
              end

              context "when sprint is not closed" do
                let(:sprint) { Sprint.new(nil, nil) }
                let(:jira_sprint) do
                  instance_double(JIRA::Resource::Sprint, attrs: { "startdate" => start_date, "enddate" => end_date })
                end

                before do
                  allow(sprint).to receive_messages(closed?: false,
                                                    jira_sprint: jira_sprint,
                                                    save: nil,
                                                    start_date: start_date,
                                                    end_date: end_date,
                                                    end_date?: end_date != Sprint::UNDEFINED_DATE,
                                                    start_date?: start_date != Sprint::UNDEFINED_DATE)
                  allow(sprint).to receive(:start_date=).and_call_original
                  allow(sprint).to receive(:end_date=).and_call_original
                end

                def get_date(date_string)
                  DateTime.parse(date_string)
                end

                context "when start and end date specified" do
                  let(:start_date) { get_date("2025-02-08 14:00 UTC") }
                  let(:end_date) { get_date("2025-02-10 14:00 UTC") }

                  it do
                    expect(sprint).to receive(:start_date=).with(get_date("2025-02-08 12:31:00 +0100"))
                    expect(sprint).to receive(:end_date=).with(get_date("2025-02-10 12:31:00 +0100"))
                    expect(sprint).to receive(:save).once

                    sprint_in_dates_aligner.update_sprint_dates_for(sprint)
                  end
                end

                context "when start and end date are unspecified" do
                  let(:start_date) { Sprint::UNDEFINED_DATE }
                  let(:end_date) { Sprint::UNDEFINED_DATE }

                  it do
                    sprint_in_dates_aligner.update_sprint_dates_for(sprint)

                    expect(sprint).not_to have_received(:save)
                  end
                end

                context "when start_date is unspecified" do
                  let(:start_date) { Sprint::UNDEFINED_DATE }
                  let(:end_date) { get_date("2025-02-14 15:00 UTC") }

                  it do
                    expect(sprint).to receive(:end_date=).with(get_date("2025-02-14 12:31:00 +0100"))
                    expect(sprint).to receive(:save).once

                    sprint_in_dates_aligner.update_sprint_dates_for(sprint)
                  end
                end

                context "when end_date is unspecified" do
                  let(:start_date) { get_date("2025-02-28 05:00 UTC") }
                  let(:end_date) { Sprint::UNDEFINED_DATE }

                  it do
                    expect(sprint).to receive(:start_date=).with(get_date("2025-02-28T12:31:00 +0100"))
                    expect(sprint).to receive(:save).once

                    sprint_in_dates_aligner.update_sprint_dates_for(sprint)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
