# frozen_string_literal: true

require "jira/auto/tool/performer/prefix_sprint_updater"

module Jira
  module Auto
    class Tool
      class Performer
        class PrefixSprintUpdater
          RSpec.describe PrefixSprintUpdater do
            let(:tool) { instance_double(Tool, unclosed_sprint_prefixes: sprint_prefixes) }
            let(:updater) { described_class.new(tool) }

            let(:sprint_prefixes) { %i[one_sprint_prefix another_sprint_prefix] }

            describe "#sprint_prefixes" do
              it { expect(updater.sprint_prefixes).to eq(sprint_prefixes) }
            end

            describe "#run" do
              it "act on the sprints for each sprint prefix" do
                allow(updater).to receive_messages(sprint_prefixes: sprint_prefixes,
                                                   act_on_sprints_for_sprint_prefix: nil)

                updater.run

                expect(updater).to have_received(:act_on_sprints_for_sprint_prefix).exactly(2).times
              end
            end
          end
        end
      end
    end
  end
end
