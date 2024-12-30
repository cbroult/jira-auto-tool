# frozen_string_literal: true

require_relative "../sprint"

module Jira
  module Auto
    class Tool
      class Sprint
        class Name
          class NameConventionError < StandardError; end

          SPRINT_PREFIX_SEPARATOR = "_"
          NUMBERING_SEPARATOR = "."
          SPRINT_NAME_REGEX = /
            (.+)                                         # prefix
            #{Regexp.escape(SPRINT_PREFIX_SEPARATOR)}
            (\d\d)                                       # year
            #{Regexp.escape(NUMBERING_SEPARATOR)}
            (\d)                                         # quarter
            #{Regexp.escape(NUMBERING_SEPARATOR)}
            (\d+)                                        # index in quarter
            $/x

          def self.parse(name_string)
            name_string =~ SPRINT_NAME_REGEX ||
              raise(NameConventionError,
                    "'#{name_string}': " \
                    "sprint name not matching #{SPRINT_NAME_REGEX}!")

            new(::Regexp.last_match(1), ::Regexp.last_match(2).to_i, ::Regexp.last_match(3).to_i,
                ::Regexp.last_match(4).to_i)
          end

          def self.build(prefix, year, quarter, index)
            new(prefix, year, quarter, index)
              .to_s
          end

          attr_accessor :prefix, :year, :quarter, :index_in_quarter

          def initialize(prefix, year, quarter, index_in_quarter)
            @prefix = prefix
            @year = year
            @quarter = quarter
            @index_in_quarter = index_in_quarter
          end

          YEAR_AS_TWO_DIGIT_RANGE = -2..-1

          def to_s
            [
              prefix,
              SPRINT_PREFIX_SEPARATOR,
              year.to_s[YEAR_AS_TWO_DIGIT_RANGE],
              NUMBERING_SEPARATOR,
              quarter,
              NUMBERING_SEPARATOR,
              index_in_quarter
            ].join
          end
        end
      end
    end
  end
end
