# frozen_string_literal: true

require "rspec"
require "active_support"
require "active_support/core_ext/string/inflections"
require "jira/auto/tool/performer/options"

module Jira
  module Auto
    class Tool
      class Performer
        module Options
          RSpec.describe Options do
            describe ".add" do
              let(:tool) { instance_double(Tool) }
              let(:parser) { OptionParser.new }

              shared_examples "a performer" do |option_use_with_args, performer_class, *expected_args|
                let(:performer_instance) { instance_double(performer_class, run: nil) }

                before do
                  allow(performer_class).to receive_messages(new: performer_instance)
                end

                it "adds a parser option to process #{option_use_with_args}" do
                  expect do
                    described_class.add(tool, parser)
                    parser.parse([option_use_with_args])
                  end.not_to raise_error

                  expect(performer_class).to have_received(:new).with(tool, *expected_args)
                  expect(performer_instance).to have_received(:run)
                end
              end

              it_behaves_like "a performer", "--sprint-add=25.3.1,4",
                              PlanningIncrementSprintCreator, "25.3.1", 4

              it_behaves_like "a performer", "--sprint-align-time-in-dates=12:00 UTC",
                              SprintTimeInDatesAligner, Time.parse("12:00 UTC")

              it_behaves_like "a performer", "--sprint-rename=old_name,new_name",
                              SprintRenamer, "old_name", "new_name"

              it_behaves_like "a performer", "--sprint-update-end-date=regex,new_end_date",
                              SprintEndDateUpdater, "regex", "new_end_date"
            end
          end
        end
      end
    end
  end
end
