Feature: Assign tickets to team sprints as per an expected start date
  In order to get some activities started by a team on a given date
  As a product owner
  I need the ability to automatically add those tickets to the corresponding sprints

  Background:
    Given a Jira Scrum board
    And tickets on the board have an expected date field named "Expected Start"
    And tickets on the board have a team field named "Implementation Team" with exactly those values:
      | values       |
      | A16 CRM      |
      | A16 E2E-Test |
      | A16 Logistic |
      | A16 Platform |
      | A16 Sys-Team |
    And the board only has the following sprints:
      | name                    | length | start                   | state  |
      | ART-16_CRM_24.4.1       | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | ART-16_CRM_24.4.2       | 2-week | 2024-12-15 11:00:00 UTC | active |
      | ART-16_E2E-Test_24.4.1  | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | ART-16_E2E-Test_24.4.2  | 4-day  | 2024-12-05 11:00:00 UTC | future |
      | ART-16_Platform_24.4.6  | 3-week | 2024-10-07 11:00:00 UTC | active |
      | ART-16_Platform_24.4.7  | 3-week | 2024-10-07 11:00:00 UTC | future |
      | ART-16_Sys-Team_24.4.12 | 1-week | 2024-12-24 11:00:00 UTC | future |
      | ART-16_Sys-Team_24.4.13 | 1-week | 2024-12-31 11:00:00 UTC | future |
      | ART-16_Sys-Team_25.1.1  | 1-week | 2025-01-07 11:00:00 UTC | future |
    And the following environment variables are set:
      | name                           | value               |
      | IMPLEMENTATION_TEAM_FIELD_NAME | Implementation Team |
      | EXPECTED_START_DATE_FIELD_NAME | Expected Start      |
      | JIRA_SPRINT_FIELD_NAME         | Sprint              |

  Scenario: List team to sprint prefix mappings
    When I successfully run `jira-auto-tool --team-sprint-mapping-list`
    Then the stdout should contain exactly:
      """
      +--------------+-----------------------------------+
      |               Team Sprint Mappings               |
      +--------------+-----------------------------------+
      | Team         | Sprint Prefix                     |
      +--------------+-----------------------------------+
      | A16 CRM      | ART-16_CRM                        |
      | A16 E2E-Test | ART-16_E2E-Test                   |
      | A16 Logistic | !!__no matching sprint prefix__!! |
      | A16 Platform | ART-16_Platform                   |
      | A16 Sys-Team | ART-16_Sys-Team                   |
      +--------------+-----------------------------------+
      """

  Scenario: Assign tickets to the relevant implementation team sprints as per the expected starts
    Given the following tickets exist:
      | summary                                                   | description                                                    | implementation_team | expected_start_date |
      | ASX-1 - Prepare repository for CI/CD                      | start date is overdue => earliest sprint                       | A16 Sys-Team        | 2024-12-05          |
      | ASX-2 - Implement stage deployment                        |                                                                | A16 Sys-Team        | 2024-12-26          |
      | ASX-3 - Prepare L&P deployment                            | start expected on sprint last day => next one                  | A16 Sys-Team        | 2024-12-31          |
      | ASX-4 - Implement prod deployment                         | starts mid sprint                                              | A16 Sys-Team        | 2025-01-01          |
      | ASX-5 - Setup monitoring dashboard                        |                                                                | A16 Sys-Team        | 2025-01-07          |
      | ASX-6 - Establish a solution wide holistic testing vision |                                                                | A16 E2E-Test        | 2024-12-04          |
      | ASX-7 - Prepare an E2E Smoke Test in CI                   | no sprint available at that time, so going to stay sprint-less | A16 E2E-Test        | 2024-12-12          |
    When I successfully run `jira-auto-tool --team-sprint-mapping-dispatch-tickets`
    Then the tickets should have been assigned to sprints as follows:
      | summary                                                   | sprint                  |
      | ASX-1 - Prepare repository for CI/CD                      | ART-16_Sys-Team_24.4.12 |
      | ASX-2 - Implement stage deployment                        | ART-16_Sys-Team_24.4.12 |
      | ASX-3 - Prepare L&P deployment                            | ART-16_Sys-Team_24.4.13 |
      | ASX-4 - Implement prod deployment                         | ART-16_Sys-Team_24.4.13 |
      | ASX-5 - Setup monitoring dashboard                        | ART-16_Sys-Team_25.1.1  |
      | ASX-6 - Establish a solution wide holistic testing vision | ART-16_E2E-Test_24.4.1  |
      | ASX-7 - Prepare an E2E Smoke Test in CI                   |                         |

  Scenario: Error Messages for tickets where no team sprint exists

  Scenario: Error Messages for tickets where no team sprint exists