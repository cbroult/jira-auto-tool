# frozen_string_literal: true

require_relative "../sprint"

module Jira
  module Auto
    class Tool
      class Sprint
        class Prefix
          include Comparable

          attr_reader :name

          def initialize(name, sprints = [])
            @name = name
            @sprints = sprints
          end

          def sprints
            @sprints.sort
          end

          def <<(sprint)
            @sprints << sprint
          end

          def add_sprints_until(until_date)
            add_sprint_following_last_one until covered?(until_date)
          end

          def covered?(until_date)
            last_sprint.end_date > until_date.time
          end

          def add_sprint_following_last_one
            self << NextSprintCreator.create_sprint_following(last_sprint)
          end

          def to_s
            "name: #{name}, sprints: #{sprints}"
          end

          def to_table_row(without_board_information: false)
            [name].concat(last_sprint.to_table_row(without_board_information:))
          end

          def self.to_table_row_header(without_board_information: false)
            sprint_header = Sprint.to_table_row_header(without_board_information: without_board_information)
            sprint_header[0] = "Last Sprint Name"

            ["Sprint Prefix"].concat(sprint_header)
          end

          def last_sprint
            log.debug { "name = #{name}, #sprints = #{sprints.size}" }
            sprints.max
          end

          def <=>(other)
            [name, sprints] <=> [other.name, other.sprints]
          end
        end
      end
    end
  end
end
