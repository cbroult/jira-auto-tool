# frozen_string_literal: true

require "rspec"

require "jira/auto/tool/performer/options"

module Jira
  module Auto
    class Tool
      class Performer
        module Options
          PERFORMER_CLASSES = [SprintTimeInDatesAligner, SprintRenamer, SprintEndDateUpdater].freeze

          RSpec.describe Options do
            describe ".add" do
              let(:tool) { instance_double(Tool) }
              let(:parser) { OptionParser.new }

              before do
                PERFORMER_CLASSES.each do |performer_class|
                  instance = instance_double(performer_class, run: nil)
                  allow(performer_class).to receive_messages(new: instance)
                end
              end

              it "adds a parser option for sprint align time in dates" do
                expect do
                  described_class.add(tool, parser)
                  parser.parse(["--sprint-align-time-in-dates=12:00"])
                end.not_to raise_error

                expect(SprintTimeInDatesAligner).to have_received(:new).with(tool, an_instance_of(Time))
              end

              it "adds a parser option for sprint rename" do
                expect do
                  described_class.add(tool, parser)
                  parser.parse(["--sprint-rename=old_name,new_name"])
                end.not_to raise_error

                expect(SprintRenamer).to have_received(:new).with(tool, "old_name", "new_name")
              end

              it "adds a parser option for sprint update end date" do
                expect do
                  described_class.add(tool, parser)
                  parser.parse(["--sprint-update-end-date=regex,new_end_date"])
                end.not_to raise_error

                expect(SprintEndDateUpdater).to have_received(:new).with(tool, "regex", "new_end_date")
              end
            end
          end
        end
      end
    end
  end
end
