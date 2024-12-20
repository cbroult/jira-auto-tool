# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class SprintStateController
        attr_reader :jira_client, :sprint

        def initialize(jira_client, sprint)
          @jira_client = jira_client
          @sprint = sprint
        end

        def transition_to(desired_state)
          transition_state(desired_state)
        end

        module SprintState
          ACTIVE = "active"
          FUTURE = "future"
          CLOSED = "closed"
        end

        STATE_TRANSITIONS =
          {
            SprintState::FUTURE => SprintState::ACTIVE,
            SprintState::ACTIVE => SprintState::CLOSED
          }.freeze

        # TODO: - write unit tests
        # TODO - fix infinite loop in case of invalid/in-existing state
        def transition_state(desired_state)
          current_state = sprint.state

          loop do
            log.debug do
              "sprint_to_update = #{sprint.name}, current_state = #{current_state} desired_state = #{desired_state}"
            end

            break if current_state == desired_state

            new_state = STATE_TRANSITIONS[current_state]

            update_sprint_state(new_state)

            current_state = new_state
          end
        end

        def update_sprint_state(new_state)
          RequestBuilder::SprintStateUpdater
            .new(jira_client, sprint: sprint, new_state: new_state)
            .run
        end
      end
    end
  end
end
