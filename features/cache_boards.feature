Feature: Cache boards
  In order to quickly manipulate sprints in a Jira instance having hundreds of boards
  As a user
  I need the boards I am interested in to be cached

  Background:
    Given the following environment variables are set:
      | name                  | value    |
      | JIRA_BOARD_NAME_REGEX | Delivery |
    And I successfully run `jira-auto-tool --board-list`

  Scenario: After being found the boards are no longer searched for
    When I successfully run `jira-auto-tool --jira-http-debug --board-list`
    Then the output contains no requests that enumerate the list of boards

  Scenario: The cache is invalidated after one hour
    Given I wait for over a day
    When I successfully run `jira-auto-tool --jira-http-debug --board-list`
    Then the output contains requests that enumerate the list of boards

  Scenario: Explicitly clear the cache
    When I successfully run `jira-auto-tool --jira-http-debug --board-cache-clear --board-list`
    Then the output contains requests that enumerate the list of boards

