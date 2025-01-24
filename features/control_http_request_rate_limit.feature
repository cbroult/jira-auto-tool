Feature: Control the HTTP request rate limit
  In order to work against a JIRA instance imposing API rate limits
  As a user
  I need the ability to control the HTTP request limit

  Scenario Outline: Limiting the request rate
    Given the following environment variables are set:
      | name                         | value           |
      | JAT_RATE_LIMIT_IN_SECONDS    | <rate_limit>    |
      | JAT_RATE_INTERVAL_IN_SECONDS | <rate_interval> |
    Then successfully running `jira-auto-tool --board-list --sprint-prefix` takes between <minimal_time> and <maximal_time> seconds

    Examples:
      | rate_limit | rate_interval | minimal_time | maximal_time |
      | 0          | 0             | 0            | 2            |
      | 1          | 2             | 1            | 10           |
      | 1          | 10            | 10           | 30           |