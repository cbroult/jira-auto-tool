Feature: Add sprints until a specific date
  In order to prepare for sprints in the future
  As an RTE
  I need the ability to add sprints until a specific date

  Background:
    Given a Jira Scrum board
    And the current date time is "2024-10-15 15:00 UTC"

  Scenario: Add sprints until specific date
    Given the board only has the following sprints:
      | expecting_added_sprints       | name                 | length | start                   | state  |
      | no since closed               | art_crm_24.4.1       | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | yes                           | art_e2e-test_24.4.1  | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | yes                           | art_people_24.4.6    | 3-week | 2024-10-07 11:00:00 UTC | active |
      | no since after specified date | art_sys-team_24.4.12 | 1-week | 2024-12-24 11:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sprint-add-until=2024-12-15`
    Then afterwards the board only has the following sprints:
      | name                 | expected_start          | state  |
      | art_crm_24.4.1       | 2024-12-01 11:00:00 UTC | closed |
      | art_e2e-test_24.4.1  | 2024-12-01 11:00:00 UTC | future |
      | art_e2e-test_24.4.2  | 2024-12-05 11:00:00 UTC | future |
      | art_e2e-test_24.4.3  | 2024-12-09 11:00:00 UTC | future |
      | art_e2e-test_24.4.4  | 2024-12-13 11:00:00 UTC | future |
      | art_people_24.4.6    | 2024-10-07 11:00:00 UTC | active |
      | art_people_24.4.7    | 2024-10-28 11:00:00 UTC | future |
      | art_people_24.4.8    | 2024-11-18 11:00:00 UTC | future |
      | art_people_24.4.9    | 2024-12-09 11:00:00 UTC | future |
      | art_sys-team_24.4.12 | 2024-12-24 11:00:00 UTC | future |

  Scenario: Add sprints until current quarter end
    Given the board only has the following sprints:
      | expecting_added_sprints                               | name                 | length | start                   | state  |
      | no since closed                                       | art_crm_24.4.1       | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | yes                                                   | art_e2e-test_24.4.1  | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | yes                                                   | art_people_24.4.6    | 3-week | 2024-10-07 11:00:00 UTC | active |
      | yes since finishes before midnight at the quarter end | art_sys-team_24.4.12 | 1-week | 2024-12-24 11:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sprint-add-until=current_quarter` for up to 120 seconds
    Then afterwards the board only has the following sprints:
      | name                 | expected_start          | state  |
      | art_crm_24.4.1       | 2024-12-01 11:00:00 UTC | closed |
      | art_e2e-test_24.4.1  | 2024-12-01 11:00:00 UTC | future |
      | art_e2e-test_24.4.2  | 2024-12-05 11:00:00 UTC | future |
      | art_e2e-test_24.4.3  | 2024-12-09 11:00:00 UTC | future |
      | art_e2e-test_24.4.4  | 2024-12-13 11:00:00 UTC | future |
      | art_e2e-test_24.4.5  | 2024-12-17 11:00:00 UTC | future |
      | art_e2e-test_24.4.6  | 2024-12-21 11:00:00 UTC | future |
      | art_e2e-test_24.4.7  | 2024-12-25 11:00:00 UTC | future |
      | art_e2e-test_24.4.8  | 2024-12-29 11:00:00 UTC | future |
      | art_people_24.4.6    | 2024-10-07 11:00:00 UTC | active |
      | art_people_24.4.7    | 2024-10-28 11:00:00 UTC | future |
      | art_people_24.4.8    | 2024-11-18 11:00:00 UTC | future |
      | art_people_24.4.9    | 2024-12-09 11:00:00 UTC | future |
      | art_people_24.4.10   | 2024-12-30 11:00:00 UTC | future |
      | art_sys-team_24.4.12 | 2024-12-24 11:00:00 UTC | future |
      | art_sys-team_24.4.13 | 2024-12-31 11:00:00 UTC | future |

  Scenario: Add sprints until the coming quarter end
    Given the board only has the following sprints:
      | expecting_added_sprints               | name                 | length | start                   | state  |
      | no since closed                       | art_crm_24.4.1       | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | no since goes over coming quarter end | art_e2e-test_25.1.9  | 4-day  | 2025-03-30 11:00:00 UTC | future |
      | yes                                   | art_people_24.4.6    | 6-week | 2024-10-07 11:00:00 UTC | active |
    When I successfully run `jira-auto-tool --sprint-add-until=coming_quarter`
    Then afterwards the board only has the following sprints:
      | name                 | expected_start          | state  |
      | art_crm_24.4.1       | 2024-12-01 11:00:00 UTC | closed |
      | art_e2e-test_25.1.9  | 2025-03-30 11:00:00 UTC | future |
      | art_people_24.4.6    | 2024-10-07 11:00:00 UTC | active |
      | art_people_24.4.7    | 2024-11-18 11:00:00 UTC | future |
      | art_people_24.4.8    | 2024-12-30 11:00:00 UTC | future |
      | art_people_25.1.1    | 2025-02-10 11:00:00 UTC | future |
      | art_people_25.1.2    | 2025-03-24 11:00:00 UTC | future |


