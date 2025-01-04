# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class Ticket
        attr_reader :jira_ticket, :summary, :implementation_team, :expected_start_date

        def initialize(jira_ticket, implementation_team, expected_start_date)
          @jira_ticket = jira_ticket
          @implementation_team = implementation_team
          @expected_start_date = expected_start_date
        end
      end
    end
  end
end
