# frozen_string_literal: true

require_relative "next_sprint_creator"
require_relative "sprint"
require_relative "sprint/prefix"
require_relative "sprint_state_controller"

module Jira
  module Auto
    class Tool
      class SprintController
        attr_accessor :tool, :board

        def initialize(tool, board)
          @tool = tool
          @board = board
        end

        def add_sprints_until(until_date)
          unclosed_sprint_prefixes.each { |prefix| prefix.add_sprints_until(until_date) }
        end

        def add_one_sprint_for_each_unclosed_sprint_prefix
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

        def list_sprints
          table = Terminal::Table.new(
            title: "Matching Sprints",
            headings: ["Sprint"],
            rows: sprints.collect { |sprint| [sprint.name] }
          )

          puts table
        end

        def sprints
          jira_sprints.collect { |sprint| Sprint.new(sprint) }
        end

        PAGE_SIZE = 50
        # rubocop:disable Metrics/MethodLength
        def jira_sprints
          sprint_filter_string = tool.art_sprint_regex_defined? ? tool.art_sprint_regex : ""
          sprint_filter_regex = Regexp.new(sprint_filter_string)

          unfiltered_jira_sprints.find_all { |sprint| sprint.name =~ sprint_filter_regex }
        end

        def unfiltered_jira_sprints
          all_jira_sprints = []
          start_at = 0

          loop do
            log.debug { "Fetching sprints from Jira (start_at: #{start_at})" }

            fetched_sprints = fetch_jira_sprints(PAGE_SIZE, start_at)

            log.warn { "Fetched #{fetched_sprints.size} sprints from Jira: #{fetched_sprints.map(&:to_s).join(" ")}" }

            all_jira_sprints.concat(fetched_sprints)
            start_at += PAGE_SIZE

            break if fetched_sprints.empty?
          end

          log.warn { all_jira_sprints }

          all_jira_sprints
        end

        # rubocop:enable Metrics/MethodLength
        NULL_FOR_URI_RESPONSE_REGEX = /null for uri:/
        def fetch_jira_sprints(max_results, start_at)
          log.warn { "Fetching sprints from Jira (max_results: #{max_results}, start_at: #{start_at})" }

          tool.jira_client.Sprint.all(maxResults: max_results, startAt: start_at)
        rescue JIRA::HTTPError => e
          log.debug { "Error fetching sprints from Jira: #{e.message.inspect}, #{e.inspect}" }

          return [] if e.message =~ NULL_FOR_URI_RESPONSE_REGEX

          raise e
        end

        def unclosed_sprints
          sprints.find_all { |sprint| sprint.state != SprintStateController::SprintState::CLOSED }
        end
      end
    end
  end
end
