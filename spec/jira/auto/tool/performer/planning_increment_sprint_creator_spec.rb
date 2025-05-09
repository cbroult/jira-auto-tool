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

            # rubocop:disable Naming/VariableNumber, RSpec/IndexedLet
            describe "#act_on_sprints_for_sprint_prefix" do
              def get_sprint(name, attributes = {})
                instance_double(Sprint, name: name, to_s: name, **attributes,
                                        parsed_name: Sprint::Name.parse(name))
              end

              let(:sprint_prefix) do
                instance_double(Sprint::Prefix, name: "Food_Delivery", last_sprint: last_sprint)
              end

              context "when the sprints to create are all posterior to the last sprint from a naming perspective" do
                let(:last_sprint) do
                  get_sprint "Food_Delivery_25.2.1", end_date: "2025-02-16 12:45", length_in_days: 10
                end

                let(:sprint_25_3_1) { get_sprint("Food_Delivery_25.3.1") }
                let(:sprint_25_3_2) { get_sprint("Food_Delivery_25.3.2") }
                let(:sprint_25_3_3) { get_sprint("Food_Delivery_25.3.3") }
                let(:sprint_25_3_4) { get_sprint("Food_Delivery_25.3.4") }

                before do
                  allow(updater).to receive(:create_sprint_for).with(last_sprint,
                                                                     "Food_Delivery_25.3.1")
                                                               .and_return(sprint_25_3_1)

                  allow(updater).to receive(:create_sprint_for).with(sprint_25_3_1, "Food_Delivery_25.3.2")
                                                               .and_return(sprint_25_3_2)

                  allow(updater).to receive(:create_sprint_for).with(sprint_25_3_2, "Food_Delivery_25.3.3")
                                                               .and_return(sprint_25_3_3)

                  allow(updater).to receive(:create_sprint_for).with(sprint_25_3_3, "Food_Delivery_25.3.4")
                                                               .and_return(sprint_25_3_4)
                end

                it "creates the expected number of sprints with the expected names" do
                  expect(sprint_prefix).to receive(:<<).with(sprint_25_3_1)
                  expect(sprint_prefix).to receive(:<<).with(sprint_25_3_2)
                  expect(sprint_prefix).to receive(:<<).with(sprint_25_3_3)
                  expect(sprint_prefix).to receive(:<<).with(sprint_25_3_4)

                  updater.act_on_sprints_for_sprint_prefix(sprint_prefix)
                end
              end

              context "when some sprints to create are anterior to the last sprint from a naming perspective" do
                let(:last_sprint) do
                  get_sprint "Food_Delivery_25.3.2", end_date: "2025-02-16 12:45", length_in_days: 10
                end

                let(:sprint_25_3_3) { get_sprint("Food_Delivery_25.3.3") }
                let(:sprint_25_3_4) { get_sprint("Food_Delivery_25.3.4") }

                before do
                  allow(updater).to receive(:create_sprint_for).with(last_sprint, "Food_Delivery_25.3.3")
                                                               .and_return(sprint_25_3_3)

                  allow(updater).to receive(:create_sprint_for).with(sprint_25_3_3, "Food_Delivery_25.3.4")
                                                               .and_return(sprint_25_3_4)
                end

                it "only creates the ones posterior to the last sprint" do
                  expect(sprint_prefix).to receive(:<<).with(sprint_25_3_3)
                  expect(sprint_prefix).to receive(:<<).with(sprint_25_3_4)

                  updater.act_on_sprints_for_sprint_prefix(sprint_prefix)
                end
              end

              context "when requested sprints to create are anterior to the last sprint from a naming perspective" do
                let(:last_sprint) do
                  get_sprint "Food_Delivery_25.4.1", end_date: "2025-02-16 12:45", length_in_days: 10
                end

                it "does not create any since they would be anterior to the last sprint" do
                  expect(updater).not_to receive(:create_sprint_for)
                  expect(sprint_prefix).not_to receive(:<<)

                  updater.act_on_sprints_for_sprint_prefix(sprint_prefix)
                end
              end
            end
            # rubocop:enable Naming/VariableNumber, RSpec/IndexedLet
          end
        end
      end
    end
  end
end
