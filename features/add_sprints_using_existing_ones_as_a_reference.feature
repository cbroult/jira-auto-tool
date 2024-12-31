Feature: Add sprints to existing ones as a reference
  In order to prepare for sprints in the future
  As an RTE
  I need the ability to add sprints using the existing ones as a reference

  Background:
    Given a Jira Scrum board

  Scenario: Board with no sprints
    Given the board has no sprint
    When I successfully run `jira-auto-tool --sprint-add-one`
    Then the output should match:
       """
       WARN.*No sprint added since no reference sprint was found!
       """

  Scenario: Board with only closed sprints
    Given the board has only closed sprints
    When I successfully run `jira-auto-tool --sprint-add-one`
    Then the output should match:
       """
       WARN.*No sprint added since no unclosed reference sprint was found!
       """

  Scenario Outline: The new sprint length is the same as the reference sprint
    Given an unclosed <sprint_length> sprint named ART_Team_24.4.5 starting on <start_date_time>
    When I successfully run `jira-auto-tool --sprint-add-one`
    Then a sprint named <expected_name> should exist
    And it starts on <expected_start>
    And it ends on <expected_end>

    Examples:
      | sprint_length | start_date_time  | expected_name   | expected_start   | expected_end     |
      | 1-week        | 2024-12-14 11:00 | ART_Team_24.4.6 | 2024-12-21 11:00 | 2024-12-28 11:00 |
      | 2-week        | 2024-12-14 14:00 | ART_Team_24.4.6 | 2024-12-28 14:00 | 2025-01-11 14:00 |
      | 3-week        | 2024-12-14 00:00 | ART_Team_25.1.1 | 2025-01-04 00:00 | 2025-01-25 00:00 |
      | 4-week        | 2024-12-14 08:00 | ART_Team_25.1.1 | 2025-01-11 08:00 | 2025-02-08 08:00 |

  Scenario: Sprint is created for each sprint prefix
    Given the board only has the following sprints:
      | expecting_added_sprint    | name                 | length | start                   | state  |
      | no                        | art_crm_24.4.6       | 2-week | 2024-12-14 11:00:00 UTC | closed |
      | yes                       | art_e2e-test_24.4.12 | 3-week | 2024-12-14 11:00:00 UTC | future |
      | yes                       | art_people_24.4.6    | 2-week | 2024-12-14 11:00:00 UTC | active |
      | yes                       | art_sys-team_24.4.12 | 1-week | 2024-12-21 11:00:00 UTC | future |
    When I run `jira-auto-tool --sprint-add-one`
    Then afterwards the board only has the following sprints:
      | name                 | expected_start          | state  |
      | art_crm_24.4.6       | 2024-12-14 11:00:00 UTC | closed |
      | art_e2e-test_24.4.12 | 2024-12-14 11:00:00 UTC | future |
      | art_e2e-test_25.1.1  | 2025-01-04 11:00:00 UTC | future |
      | art_people_24.4.6    | 2024-12-14 11:00:00 UTC | active |
      | art_people_24.4.7    | 2024-12-28 11:00:00 UTC | future |
      | art_sys-team_24.4.12 | 2024-12-21 11:00:00 UTC | future |
      | art_sys-team_24.4.13 | 2024-12-28 11:00:00 UTC | future |

  Scenario: Sprint is created using the last sprint of a sprint prefix
    Given the board only has the following sprints:
      | expecting_added_sprint                  | name                 | length | start                   | state  |
      | ignored since not last existing sprint  | art_sys-team_24.4.10 | 1-week | 2024-12-01 11:00:00 UTC | future |
      | ignored since not last existing sprint  | art_sys-team_24.4.11 | 1-week | 2024-12-05 11:00:00 UTC | future |
      | yes                                     | art_sys-team_24.4.12 | 2-week | 2024-12-14 11:00:00 UTC | future |

    When I run `jira-auto-tool --sprint-add-one`
    Then afterwards the board only has the following sprints:
      | name                 | expected_start          | state  |
      | art_sys-team_24.4.10 | 2024-12-01 11:00:00 UTC | future |
      | art_sys-team_24.4.11 | 2024-12-05 11:00:00 UTC | future |
      | art_sys-team_24.4.12 | 2024-12-14 11:00:00 UTC | future |
      | art_sys-team_24.4.13 | 2024-12-28 11:00:00 UTC | future |
