# frozen_string_literal: true

require "rspec"
require "active_support/testing/time_helpers"
require "jira/auto/tool/until_date"

module Jira
  module Auto
    class Tool
      RSpec.describe Jira::Auto::Tool::UntilDate do
        it "accepts a date with time" do
          expect(described_class.new("2024-12-19 13:16 UTC").time).to eq(Time.new(2024, 12, 19, 13, 16, 0, "+00:00"))
        end

        RSpec::Matchers.define :be_date_until_midnight_utc do |expected_year, expected_month, expected_day|
          def date_until_midnight_utc(expected_year, expected_month, expected_day)
            Time.new(expected_year, expected_month, expected_day, 23, 59, 59, "UTC").end_of_day
          end

          match do |actual_until_date|
            @date_until_midnight_utc = date_until_midnight_utc(expected_year, expected_month, expected_day)

            expect(actual_until_date.time).to eq(@date_until_midnight_utc)
          end

          failure_message { |actual_until_date| build_message(actual_until_date) }
          failure_message_when_negated { |actual_until_date| build_message(actual_until_date, "not ") }

          def build_message(actual_until_date, negation_part = "")
            "expected #{actual_until_date.inspect} #{negation_part}to be equal to #{@date_until_midnight_utc.inspect}"
          end
        end

        context "when no time specified it adds the time until midnight UTC" do
          it do
            expect(described_class.new("2025-01-01")).to be_date_until_midnight_utc(2025, 1, 1)
          end
        end

        context "when using named dates it converts to the time until midnight UTC" do
          include ActiveSupport::Testing::TimeHelpers

          let(:third_quarter_time) { Time.new(2024, 9, 16, 12, 0, 0, "+00:00") }

          before { travel_to(third_quarter_time) }
          after { travel_back }

          it do
            expect(described_class.new("today")).to be_date_until_midnight_utc(2024, 9, 16)
          end

          it do
            expect(described_class.new("current_quarter")).to be_date_until_midnight_utc(2024, 9, 30)
          end

          it do
            expect(described_class.new("coming_quarter")).to be_date_until_midnight_utc(2024, 12, 31)
          end
        end

        context "when unexpected date format" do
          it "raises an error" do
            expect { described_class.new("current-quarter-end") }
              .to raise_error(UntilDate::FormatError, "date string 'current-quarter-end' is not in a supported format")
          end
        end

        describe "#current_date_time" do
          let(:time_now) { Time.new(2024, 9, 16, 12, 0, 0, "+00:00") }

          it "uses an overridable time source" do
            allow(Helpers::OverridableTime).to receive_messages(now: time_now)

            expect(described_class.new("current_quarter").current_date_time).to eq(time_now)
          end
        end
      end
    end
  end
end
