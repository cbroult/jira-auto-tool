Feature: Sprint Filtering
  In order to target specific sprints
  As a user
  I need the ability to filter sprints

  Background:
    Given a Jira Scrum board
    And the board only has the following sprints:
      | name                    | length | start                   | state  |
      | ART-16_CRM_24.4.1       | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | ART-16_E2E-Test_24.4.1  | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | ART-32_Sys-Team_24.4.12 | 1-week | 2024-12-24 11:00:00 UTC | future |
      | ART-32_Sys-Team_25.1.1  | 1-week | 2025-01-07 11:00:00 UTC | future |
      | ART-16_E2E-Test_24.4.2  | 4-day  | 2024-12-05 11:00:00 UTC | future |
      | ART-32_Platform_24.4.7  | 3-week | 2024-10-07 11:00:00 UTC | future |


  Scenario: No filter applied except ignoring closed sprints
    When I successfully run `jira-auto-tool --sprint-list`
    Then the output should match:
      """
      \+-------\+-------------------------\+----------------\+-------------------------\+-------------------------\+-----------------------\+---------------------------------+--\+-------------------\+
      \|                                                                         \s+   Matching Sprints                                                                     \s+                       \|
      \+-------\+-------------------------\+----------------\+-------------------------\+-------------------------\+-----------------------\+---------------------------------+--\+-------------------\+
      \| Id    \| Name                    \| Length In Days \| Start Date              \| End Date                \| Board Name            \| Board UI URL                  \s+  \| Board Project Key \|
      \+-------\+-------------------------\+----------------\+-------------------------\+-------------------------\+-----------------------\+---------------------------------+--\+-------------------\+
      """
    And the output should match:
      """
      .+-------------------------.+
      .+ Name                    .+
      .+-------------------------.+
      .+ ART-32_Platform_24.4.7  .+
      .+ ART-16_E2E-Test_24.4.1  .+
      .+ ART-16_E2E-Test_24.4.2  .+
      .+ ART-32_Sys-Team_24.4.12 .+
      .+ ART-32_Sys-Team_25.1.1  .+
      .+-------------------------.+
      """

  Scenario: No filtering (except closed sprints) and excluding the corresponding board information
    When I successfully run `jira-auto-tool --sprint-list-without-board-info`
    Then the stdout should contain:
      """
      +-------+-------------------------+----------------+-------------------------+-------------------------+
      |                                           Matching Sprints                                           |
      +-------+-------------------------+----------------+-------------------------+-------------------------+
      | Id    | Name                    | Length In Days | Start Date              | End Date                |
      +-------+-------------------------+----------------+-------------------------+-------------------------+
      """
    And the output should match:
      """
      .+-------------------------.+
      .+ Name                    .+
      .+-------------------------.+
      .+ ART-32_Platform_24.4.7  .+
      .+ ART-16_E2E-Test_24.4.1  .+
      .+ ART-16_E2E-Test_24.4.2  .+
      .+ ART-32_Sys-Team_24.4.12 .+
      .+ ART-32_Sys-Team_25.1.1  .+
      .+-------------------------.+
      """

  Scenario: Filter sprints with a string
    Given the following environment variables are set:
      | name                            | value               |
      | ART_SPRINT_REGEX                | ART-16              |
    When I successfully run `jira-auto-tool --sprint-list`
    Then the output should match:
      """
      \+-------\+---------+--------\+----------------\+-------------------------\+-------------------------\+-----------------------\+---------------------------------+--\+-------------------\+
      \|                                                                       \s+   Matching Sprints                                                                \s+                       \|
      \+-------\+---------+--------\+----------------\+-------------------------\+-------------------------\+-----------------------\+---------------------------------+--\+-------------------\+
      \| Id    \| Name  \s+        \| Length In Days \| Start Date              \| End Date                \| Board Name            \| Board UI URL                  \s+  \| Board Project Key \|
      \+-------\+---------+--------\+----------------\+-------------------------\+-------------------------\+-----------------------\+---------------------------------+--\+-------------------\+
      """
    And the output should match:
      """
      .*------------------------.*
      .*                        .*
      .*------------------------.*
      .* Name                   .*
      .*------------------------.*
      .* ART-16_E2E-Test_24.4.1 .*
      .* ART-16_E2E-Test_24.4.2 .*
      .*------------------------.*
      """
  Scenario: Filter sprints with a regular expression
    Given the following environment variables are set:
      | name             | value  |
      | ART_SPRINT_REGEX | Platform\|(4\.1)$ |
    When I successfully run `jira-auto-tool --sprint-list`
    Then the output should match:
      """
      \+-------\+---------+-------\+----------------\+-------------------------\+-------------------------\+-----------------------\+---------------------------------+--\+-------------------\+
      \|                                                                      \s+   Matching Sprints                                                                \s+                       \|
      \+-------\+---------+-------\+----------------\+-------------------------\+-------------------------\+-----------------------\+---------------------------------+--\+-------------------\+
      \| Id    \| Name  \s+       \| Length In Days \| Start Date              \| End Date                \| Board Name            \| Board UI URL                  \s+  \| Board Project Key \|
      \+-------\+---------+-------\+----------------\+-------------------------\+-------------------------\+-----------------------\+---------------------------------+--\+-------------------\+
      """
    And the output should match:
      """
      .+------------------------.+
      .+ Name                   .+
      .+------------------------.+
      .+ ART-32_Platform_24.4.7 .+
      .+ ART-16_E2E-Test_24.4.1 .+
      .+------------------------.+
      """

