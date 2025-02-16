# frozen_string_literal: true

require "rspec"

require "jira/auto/tool/performer/planning_increment_sprint_creator"

module Jira
  module Auto
    class Tool
      class Performer
        class PlanningIncrementSprintCreator
          RSpec.describe PlanningIncrementSprintCreator do
            let(:updater) { described_class.new(tool, "25.3.1", 4) }
            let(:tool) { instance_double(Tool) }

            def get_date(date_string)
              Time.parse(date_string)
            end

            describe "#create_sprint_for" do
              let(:last_sprint) do
                instance_double(Sprint, origin_board_id: 64,
                                        end_date: get_date("2025-02-16 15:06"), length_in_days: 4)
              end

              it "creates a sprint" do
                expect(RequestBuilder::SprintCreator).to receive(:create_sprint).with(
                  tool, 64, name: "Food_Restaurant_25.3.1",
                            start_date: get_date("2025-02-16 15:06"), length_in_days: 4
                )

                updater.create_sprint_for(last_sprint, "Food_Restaurant_25.3.1")
              end
            end

            describe "#act_on_sprints_for_sprint_prefix" do
              def get_sprint(name, attributes)
                instance_double(Sprint, name: name, to_s: name, **attributes)
              end

              let(:last_sprint) { get_sprint "Food_Delivery_25.2.1", end_date: "2025-02-16 12:45", length_in_days: 10 }

              let(:sprint_prefix) { instance_double(Sprint::Prefix, name: "Food_Delivery", last_sprint: last_sprint) }

              # rubocop:disable RSpec/MultipleExpectations
              it "creates the expected number of sprints with the expected names" do
                expect(updater).to receive(:create_sprint_for).ordered.with(last_sprint, "Food_Delivery_25.3.1")
                expect(updater).to receive(:create_sprint_for).ordered.with(nil, "Food_Delivery_25.3.2")
                expect(updater).to receive(:create_sprint_for).ordered.with(nil, "Food_Delivery_25.3.3")
                expect(updater).to receive(:create_sprint_for).ordered.with(nil, "Food_Delivery_25.3.4")
                expect(sprint_prefix).to receive(:<<).exactly(4).times

                updater.act_on_sprints_for_sprint_prefix(sprint_prefix)
              end
              # rubocop:enable RSpec/MultipleExpectations
            end
          end
        end
      end
    end
  end
end
