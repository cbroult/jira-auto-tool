Feature: Control the HTTP request rate limit
  In order to work against a JIRA instance imposing API rate limits
  As a user
  I need the ability to control the HTTP request limit

  Scenario Outline: Limiting the request rate
    Given a Jira Scrum board
    And the board only has the following sprints:
      | name                    | length | start_date              | state  |
      | ART-16_CRM_24.4.1       | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | ART-16_E2E-Test_24.4.2  | 4-day  | 2024-12-05 11:00:00 UTC | future |
      | ART-32_Platform_24.4.7  | 3-week | 2024-10-07 11:00:00 UTC | future |
    And the following environment variables are set:
      | name                          | value                           |
      | JAT_RATE_INTERVAL_IN_SECONDS  | <rate_interval_in_seconds>      |
      | JAT_RATE_LIMIT_IMPLEMENTATION | <jat_rate_limit_implementation> |
      | JAT_RATE_LIMIT_PER_INTERVAL   | <rate_limit_per_interval>       |
    Then successfully running `jira-auto-tool --board-list --sprint-prefix` takes between <minimal_time> and <maximal_time> seconds

    Examples:
      | jat_rate_limit_implementation | rate_limit_per_interval | rate_interval_in_seconds | minimal_time | maximal_time |
      |                               | 0                       | 0                        | 0            | 7            |
      | in_process                    | 1                       | 1                        | 1            | 20           |
      | redis                         | 1                       | 2                        | 1            | 20           |
      | redis                         | 1                       | 10                       | 18           | 120          |

  Scenario: Unexpected rate limiting implementation generates an error
    Given the following environment variables are set:
      | name                          | value                  |
      | JAT_RATE_LIMIT_IMPLEMENTATION | UNKNOWN IMPLEMENTATION |
    When I run `jira-auto-tool --board-list`
    Then it should fail with:
      """
      RuntimeError: "UNKNOWN IMPLEMENTATION": unexpected rate limiting implementation specified!
      """
