@in-specification
Feature: Assign tickets to team sprints as per an expected start date
  In order to get some activities started by a team on a given date
  As a product owner
  I need the ability to automatically add those tickets to the corresponding sprints

  Background:
    Given a Jira Scrum board
    And tickets on the board have an expected date field named "Expected Start"
    And tickets on the board have a team field named "Implementation Team" with exactly those values:
      | values         |
      | ART 16 CRM      |
      | ART 16 E2E-Test |
      | ART 16 Platform |
      | ART 16 Sys-Team |
    And the board only has the following sprints:
      | name                   | length | start                   | state  |
      | ART-16_CRM_24.4.1       | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | ART-16_CRM_24.4.2       | 2-week | 2024-12-15 11:00:00 UTC | active |
      | ART-16_E2E-test_24.4.1  | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | ART-16_E2E-test_24.4.2  | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | ART-16_Platform_24.4.6  | 3-week | 2024-10-07 11:00:00 UTC | active |
      | ART-16_Platform_24.4.7  | 3-week | 2024-10-07 11:00:00 UTC | future |
      | ART-16_Sys-Team_24.4.12 | 1-week | 2024-12-24 11:00:00 UTC | future |
      | ART-16_Sys-Team_24.4.12 | 1-week | 2024-12-24 11:00:00 UTC | future |

  Scenario: List team to sprint prefix mappings
    When I successfully run `jira-auto-tool --team-sprint-mapping-list`
    Then the output should contain:
      | team_name      | sprint                 |
      | ART 16 CRM      | ART-16_CRM_24.4.2       |
      | ART 16 E2E-Test | ART-16_E2E-test_24.4.1  |
      | ART 16 E2E-Test | ART-16_E2E-test_24.4.2  |
      | ART 16 Platform | ART-16_Platform_24.4.6  |
      | ART 16 Platform | ART-16_Platform_24.4.7  |
      | ART 16 Sys-Team | ART-16_Sys-Team_24.4.12 |
      | ART 16 Sys-Team | ART-16_Sys-Team_24.4.12 |

Scenario: Assign tickets to the relevant implementation team sprints as per the expected starts
  Given the following tickets exist:
    | summary | team | expected_start |
    |         |      |                |
  When I successfully run `jira-auto-tool --ticket-dispatch-to-team-sprints`
  Then the tickets should have the following attributes:
    | summary | team | expected_start | sprint |
    |         |      |                |        |



