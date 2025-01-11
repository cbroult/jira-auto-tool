Feature: List Sprint Prefixes
  In order to confirm the next sprints are going to be created after the correct last sprints
  As a user
  I need the ability to list the sprint prefixes and their corresponding last sprint

  Background:
    Given a Jira Scrum board
    And the board only has the following sprints:
      | name                    | length | start                   | state  |
      | ART-16_CRM_24.4.1       | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | ART-16_E2E-Test_24.4.1  | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | ART-16_E2E-Test_24.4.2  | 4-day  | 2024-12-05 11:00:00 UTC | future |
      | ART-32_Platform_24.4.7  | 3-week | 2024-10-07 11:00:00 UTC | future |
      | ART-32_Sys-Team_24.4.12 | 1-week | 2024-12-24 11:00:00 UTC | future |
      | ART-32_Sys-Team_25.1.1  | 1-week | 2025-01-07 11:00:00 UTC | future |


  Scenario: No filter applied
    When I successfully run `jira-auto-tool --sprint-prefix-list-without-board-info`
    Then the stdout should contain exactly:
      """
      +-----------------+------------------------+----------------+-------------------------+-------------------------+
      |                                Sprint Prefixes With Corresponding Last Sprints                                |
      +-----------------+------------------------+----------------+-------------------------+-------------------------+
      | Sprint Prefix   | Last Sprint Name       | Length In Days | Start Date              | End Date                |
      +-----------------+------------------------+----------------+-------------------------+-------------------------+
      | ART-16_E2E-Test | ART-16_E2E-Test_24.4.2 | 4.0            | 2024-12-05 11:00:00 UTC | 2024-12-09 11:00:00 UTC |
      | ART-32_Platform | ART-32_Platform_24.4.7 | 21.0           | 2024-10-07 11:00:00 UTC | 2024-10-28 11:00:00 UTC |
      | ART-32_Sys-Team | ART-32_Sys-Team_25.1.1 | 7.0            | 2025-01-07 11:00:00 UTC | 2025-01-14 11:00:00 UTC |
      +-----------------+------------------------+----------------+-------------------------+-------------------------+
      """

  Scenario: No filtering and including the corresponding board information
    When I successfully run `jira-auto-tool --sprint-prefix-list`
    Then the stdout should contain:
      """
      +-----------------+------------------------+----------------+-------------------------+-------------------------+------------------+--------------------------------------------------------------------------------+-------------------+
      |                                                                                            Sprint Prefixes With Corresponding Last Sprints                                                                                            |
      +-----------------+------------------------+----------------+-------------------------+-------------------------+------------------+--------------------------------------------------------------------------------+-------------------+
      | Sprint Prefix   | Last Sprint Name       | Length In Days | Start Date              | End Date                | Board Name       | Board UI URL                                                                   | Board Project Key |
      +-----------------+------------------------+----------------+-------------------------+-------------------------+------------------+--------------------------------------------------------------------------------+-------------------+
      """

