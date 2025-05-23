# frozen_string_literal: true

require_relative "next_sprint_creator"
require_relative "sprint"
require_relative "sprint/prefix"
require_relative "sprint_state_controller"
require_relative "helpers/pagination"

module Jira
  module Auto
    class Tool
      class SprintController
        attr_accessor :tool, :board

        def initialize(tool, board)
          @tool = tool
          @board = board
        end

        def quarterly_add_sprints_until(until_date)
          unclosed_sprint_prefixes.each { |prefix| prefix.quarterly_add_sprints_until(until_date) }
        end

        def quarterly_add_one_sprint_for_each_unclosed_sprint_prefix
          exit_with_board_warning "No sprint added since no reference sprint was found!" unless sprint_exist?
          unless unclosed_sprint_exist?
            exit_with_board_warning "No sprint added since no unclosed reference sprint was found!"
          end

          unclosed_sprint_prefixes.each(&:add_sprint_following_last_one)
        end

        SUCCESSFUL_EXECUTION_EXIT_CODE = 0
        UNSUCCESSFUL_EXECUTION_EXIT_CODE = 1

        def exit_with_board_warning(message, exit_code = SUCCESSFUL_EXECUTION_EXIT_CODE)
          log.warn { "Jira board '#{board.name}': #{message}" }
          exit(exit_code)
        end

        def unclosed_sprint_prefixes
          @unclosed_sprint_prefixes ||= calculate_unclosed_sprint_prefixes.sort_by(&:name)
        end

        def unclosed_sprint_exist?
          !unclosed_sprints.empty?
        end

        def sprint_exist?
          !sprints.empty?
        end

        def list_sprint_prefixes(without_board_information: false)
          list_object(Sprint::Prefix, :unclosed_sprint_prefixes,
                      "Sprint Prefixes With Corresponding Last Sprints",
                      without_board_information: without_board_information)
        end

        def list_sprints(without_board_information: false)
          list_object(Sprint, :unclosed_sprints, "Matching Sprints",
                      without_board_information: without_board_information)
        end

        def list_object(object_class, object_method, title, without_board_information: false)
          table_row_header = object_class.to_table_row_header(without_board_information: without_board_information)

          rows = send(object_method).collect do |sprint|
            sprint.to_table_row(without_board_information: without_board_information)
          end

          table = Terminal::Table.new(
            title: title,
            headings: table_row_header,
            rows: rows
          )

          puts table
        end

        def sprints
          jira_sprints.collect { |jira_sprint| Sprint.new(tool, jira_sprint) }
                      .uniq(&:id)
                      .sort
        end

        def jira_sprints
          sprint_filter_string = tool.art_sprint_regex_defined? ? tool.art_sprint_regex : ""
          sprint_filter_regex = Regexp.new(sprint_filter_string)

          unfiltered_board_sprints.find_all { |sprint| sprint.name =~ sprint_filter_regex }
        end

        def unfiltered_board_sprints
          all_board_sprints = []

          sprint_compatible_boards.each do |board|
            all_board_sprints.concat(unfiltered_jira_sprints(board))
          end

          all_board_sprints
        end

        def sprint_compatible_boards
          boards.find_all(&:sprint_compatible?)
        end

        def boards
          tool.board_controller.boards
        end

        def unfiltered_jira_sprints(board)
          Helpers::Pagination.fetch_all_object_pages do |pagination_options|
            fetch_jira_sprints(board, pagination_options)
          end
        end

        def fetch_jira_sprints(board, options)
          log.debug { "Fetching sprints from Jira (#{options.inspect})" }

          fetched_sprints = board.jira_board.sprints(options)

          log.debug do
            "Board: #{board.name}: Fetched #sprints #{fetched_sprints.size} sprints from Jira: " \
              "#{fetched_sprints.map(&:name).join(", ")}"
          end

          fetched_sprints
        end

        def unclosed_sprints
          sprints.find_all { |sprint| sprint.state != SprintStateController::SprintState::CLOSED }
        end

        private

        def calculate_unclosed_sprint_prefixes
          unclosed_sprints.each_with_object({}) do |sprint, prefixes|
            if Sprint::Name.respects_naming_convention?(sprint.name)
              prefix = prefixes[sprint.name_prefix] ||= Sprint::Prefix.new(sprint.name_prefix)
              prefix << sprint
            else
              log.warn do
                "IGNORING sprint '#{sprint.name}' (board '#{board.name}'): " \
                  "it does not respect the naming conventions #{Sprint::Name::SPRINT_NAME_REGEX}."
              end
            end
          end.values
        end
      end
    end
  end
end
