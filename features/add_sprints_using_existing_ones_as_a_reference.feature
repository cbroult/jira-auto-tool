@wip
Feature: Add sprints to existing ones as a reference
  In order to prepare for sprints in the future
  As an RTE
  I need the ability to add sprints using the existing ones as a reference

  Background:
    Given a Jira Scrum board

  Scenario: Board with no sprints
    Given the board has no sprint
    When I successfully run `jira-sprint-tool --sprint-add-one`
    Then the output should match:
       """
       WARN.*No sprint added since no reference sprint was found!
       """

  Scenario: Board with only closed sprints
    Given the board has only closed sprints
    When I successfully run `jira-sprint-tool --sprint-add-one`
    Then its stdout output should contain:
       """
       No sprint added since no unclosed reference sprint was found!
       """

  @in-specification
  Scenario Outline: The new sprint length is the same as the reference sprint
    Given an unclosed <sprint-length> sprint named "ART_Team_24.4.5" starting on <start-date-time>
    When I successfully run `jira-sprint-tool --sprint-add-one`
    Then a sprint named <expected-name> should exist
    And it starts on <expected-start>
    And it ends on <expected-end>

    Examples:
      | sprint-length | start-date-time  | expected-name   | expected-start   | expected-end     |
      | 1-week        | 2024-12-14 11:00 | ART_Team_24.4.6 | 2024-12-21 11:00 | 2024-12-21 11:00 |
      | 2-week        | 2024-12-14 14:00 | ART_Team_24.4.6 | 2024-12-28 14:00 | 2025-01-04 14:00 |
      | 3-week        | 2024-12-14 00:00 | ART_Team_25.1.1 | 2024-01-04 00:00 | 2025-01-25 00:00 |
      | 4-week        | 2024-12-14 08:00 | ART_Team_25.1.1 | 2024-01-04 08:00 | 2025-01-25 08:00 |

  @in-specification
  Scenario: Sprint is created for each sprint prefix
    Given the board only has the following sprints:
      | expecting-added-sprint    | name                 | length | start-date-time  | state  |
      | no                        | art_crm_24.4.6       | 2-week | 2024-12-14 11:00 | closed |
      | yes                       | art_people_24.4.6    | 2-week | 2024-12-14 11:00 | active |
      | yes                       | art_sys-team_24.4.12 | 1-week | 2024-12-21 11:00 | future |
      | yes                       | art_e2e-test_24.4.12 | 3-week | 2024-12-14 11:00 | future |
    When I run `jira-sprint-tool --sprint-add-one`
    Then afterwards the board only has the following sprints:
      | name                 | expected-start   | expected-end   | state  |
      | art_crm_24.4.6       | 2024-12-14 11:00 | 2024-12-28 11:00 | closed |
      | art_people_24.4.6    | 2024-12-14 11:00 | 2024-12-28 11:00 | active |
      | art_people_24.4.7    | 2024-12-28 11:00 | 2025-01-11 11:00 | future |
      | art_sys-team_24.4.12 | 2024-12-21 11:00 | 2024-12-28 11:00 | future |
      | art_sys-team_24.4.13 | 2024-12-28 11:00 | 2025-01-04 11:00 | future |
      | art_e2e-test_24.4.12 | 2024-12-14 11:00 | 2024-01-04 11:00 | future |
      | art_e2e-test_25.1.1  | 2024-01-04 11:00 | 2024-01-25 11:00 | future |
