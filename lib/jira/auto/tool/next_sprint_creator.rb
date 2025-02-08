# frozen_string_literal: true

require "delegate"
require "jira-ruby"

require_relative "sprint_state_controller"
require_relative "sprint/name"

module Jira
  module Auto
    class Tool
      class NextSprintCreator
        def self.create_sprint_following(sprint)
          new(sprint).create
        end

        attr_reader :sprint

        def initialize(sprint)
          log.debug { "Creating next sprint for #{sprint}" }
          @sprint = sprint
        end

        def next_sprint_length_in_days
          sprint.length_in_days
        end

        def create
          RequestBuilder::SprintCreator.create_sprint(sprint.tool, sprint.origin_board_id, {
                                                        name: next_sprint_name,
                                                        start_date: next_sprint_start_date.utc.to_s,
                                                        length_in_days: next_sprint_length_in_days
                                                      })
        end

        INDEX_FIRST_SPRINT_IN_QUARTER = 1

        def next_sprint_name
          index_in_quarter =
            if same_quarter?
              sprint.index_in_quarter + 1
            else
              INDEX_FIRST_SPRINT_IN_QUARTER
            end

          Sprint::Name.new(sprint.name_prefix, next_sprint_start_date.year, next_sprint_start_date.quarter,
                           index_in_quarter).to_s
        end

        def same_quarter?
          sprint.start_date.quarter == next_sprint_start_date.quarter
        end

        def next_sprint_start_date
          sprint.end_date
        end
      end
    end
  end
end
