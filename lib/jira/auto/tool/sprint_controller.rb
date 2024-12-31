# frozen_string_literal: true

require_relative "next_sprint_creator"
require_relative "sprint"
require_relative "sprint/prefix"
require_relative "sprint_state_controller"

module Jira
  module Auto
    class Tool
      class SprintController
        attr_accessor :board

        def initialize(board)
          @board = board
        end

        def add_one_sprint_for_each_unclosed_sprint_prefix
          exit_with_board_warning "No sprint added since no reference sprint was found!" unless sprint_exist?
          unless unclosed_sprint_exist?
            exit_with_board_warning "No sprint added since no unclosed reference sprint was found!"
          end

          unclosed_sprint_prefixes.each do |unclosed_sprint_prefix|
            NextSprintCreator.create_sprint_following(unclosed_sprint_prefix.last_sprint)
          end
        end

        SUCCESSFUL_EXECUTION_EXIT_CODE = 0
        UNSUCCESSFUL_EXECUTION_EXIT_CODE = 1
        def exit_with_board_warning(message, exit_code = SUCCESSFUL_EXECUTION_EXIT_CODE)
          log.warn { "Jira board '#{board.name}': #{message}" }
          exit(exit_code)
        end

        def unclosed_sprint_prefixes
          @unclosed_sprint_prefixes ||= unclosed_sprints.each_with_object({}) do |sprint, prefixes|
            prefix = prefixes[sprint.name_prefix] ||= Sprint::Prefix.new(sprint.name_prefix)
            prefix << sprint
          end.values
        end

        def unclosed_sprint_exist?
          !unclosed_sprints.empty?
        end

        def sprint_exist?
          !sprints.empty?
        end

        def sprints
          board.sprints.collect { |sprint| Sprint.new(sprint, board.id) }
        end

        def unclosed_sprints
          sprints.find_all { |sprint| sprint.state != SprintStateController::SprintState::CLOSED }
        end
      end
    end
  end
end
