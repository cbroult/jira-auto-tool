# frozen_string_literal: true

require_relative "request_builder/sprint_creator"
require_relative "request_builder/sprint_state_updater"

module Jira
  module Auto
    class Tool
      class UntilDate
        class FormatError < RuntimeError; end

        attr_reader :time

        NAMED_DATES = %i[
          today
          current_quarter
          coming_quarter
        ].freeze

        NAMED_DATE_REGEX = /^(#{NAMED_DATES.join("|")})$/

        INCLUDES_TIME_REGEX = /.+\s\d{2}:\d{2}.+/
        STARTS_WITH_DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/ # TODO : use something more reliable like the Chronic gem
        TIME_UNTIL_MIDNIGHT_UTC = " 23:59:59 UTC"

        def initialize(date_string)
          @time =
            case date_string
            when NAMED_DATE_REGEX
              send(date_string.intern)
            else
              parse_date(date_string)
            end
        end

        def current_time
          Time.now.utc
        end

        private

        def parse_date(date_string)
          case date_string
          when INCLUDES_TIME_REGEX
            Time.parse(date_string)
          when STARTS_WITH_DATE_REGEX
            Time.parse(date_string + TIME_UNTIL_MIDNIGHT_UTC).end_of_day
          else
            raise FormatError, "date string '#{date_string}' is not in a supported format"
          end
        end

        def today
          current_time.end_of_day
        end

        def current_quarter
          today.end_of_quarter
        end

        def coming_quarter
          (current_quarter + 1.day).end_of_quarter
        end
      end
    end
  end
end
