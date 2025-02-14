# frozen_string_literal: true

require "rspec"

require "jira/auto/tool/performer/sprint_end_date_updater"

module Jira
  module Auto
    class Tool
      class Performer
        class SprintEndDateUpdater
          RSpec.describe SprintEndDateUpdater do
            let(:updater) { described_class.new(tool, "25.2.2", new_end_date_string) }
            let(:tool) { instance_double(Tool) }
            let(:new_end_date_string) { "2025-02-14 15:38" }
            let(:new_end_date) { get_date(new_end_date_string) }

            def get_date(date_string)
              Time.parse(date_string)
            end

            describe "#update_sprint_end_date" do
              let(:sprint) { instance_double(Sprint, :end_date= => nil, :save => nil, :length_in_days => 10) }

              it do
                updater.update_sprint_end_date(sprint)

                expect(sprint).to have_received(:end_date=).with(new_end_date)
                expect(sprint).to have_received(:save)
              end
            end

            describe "#shift_sprint_to_new_start_date" do
              let(:sprint) { instance_double(Sprint, length_in_days: 10, save: nil) }

              let(:new_start_date) { get_date("2025-03-21 15:38") }

              it "keeps the the sprint length unchanged" do
                allow(sprint).to receive(:start_date=).with(new_start_date)
                allow(sprint).to receive(:end_date=).with(get_date("2025-03-31 15:38"))

                updater.shift_sprint_to_new_start_date(sprint, new_start_date)

                expect(sprint).to have_received(:save)
              end
            end

            # rubocop:disable RSpec/MultipleMemoizedHelpers
            describe "#act_on_sprints_for_sprint_prefix" do
              def get_sprint(name, attributes)
                instance_double(Sprint, name: name, to_s: name, **attributes)
              end

              let(:a_sprint_that_should_not_change) { get_sprint "Food_Delivery_25.2.1", end_date: nil }

              let(:a_that_should_get_a_new_end_date) do
                get_sprint "Food_Delivery_25.2.2", end_date: get_date("2025-03-21 15:38")
              end

              let(:a_sprint_that_should_get_shifted_with_a_new_start_date) do
                get_sprint "Food_Delivery_25.2.3", end_date: get_date("2025-03-31 15:38")
              end

              let(:sprints) do
                [a_sprint_that_should_not_change,
                 a_that_should_get_a_new_end_date,
                 a_sprint_that_should_get_shifted_with_a_new_start_date]
              end

              let(:sprint_prefix) { instance_double(Sprint::Prefix, sprints: sprints) }

              it "the prefix sprints as per expectations" do
                expect(updater).to receive(:do_nothing).with(a_sprint_that_should_not_change, nil)
                expect(updater).to receive(:update_sprint_end_date).with(a_that_should_get_a_new_end_date)

                expect(updater).to receive(:shift_sprint_to_new_start_date).with(
                  a_sprint_that_should_get_shifted_with_a_new_start_date,
                  get_date("2025-03-21 15:38")
                )

                updater.act_on_sprints_for_sprint_prefix(sprint_prefix)
              end
            end
            # rubocop:enable RSpec/MultipleMemoizedHelpers
          end
        end
      end
    end
  end
end
