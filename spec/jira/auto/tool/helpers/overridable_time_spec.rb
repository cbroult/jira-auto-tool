# frozen_string_literal: true

require "jira/auto/tool/helpers/overridable_time"

module Jira
  module Auto
    class Tool
      module Helpers
        class OverridableTime
          RSpec.describe OverridableTime do
            describe ".now" do
              let(:time_from_now) { Time.new(2025, 1, 1, 16, 32, 0, "UTC") }

              it "returns the current date time" do
                allow(Time).to receive_messages(now: time_from_now)

                expect(described_class.now).to eq(time_from_now)
              end

              context "when the current date time is overridden" do
                before do
                  @previous_date_override = ENV.fetch("JAT_CURRENT_DATE_TIME", nil)
                end

                after do
                  ENV["JAT_CURRENT_DATE_TIME"] = @previous_date_override
                end

                let(:overridden_date_time_string) { "2024-04-16 16:32 UTC" }

                it "can be overridden using the JAT_CURRENT_DATE_TIME environment variable (e.g., for testing)" do
                  ENV["JAT_CURRENT_DATE_TIME"] = overridden_date_time_string

                  expect(described_class.now).to eq(Time.parse(overridden_date_time_string))
                end
              end
            end
          end
        end
      end
    end
  end
end
