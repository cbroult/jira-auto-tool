Feature: Add sprints using existing ones as reference
  In order to prepare for multi-team sprints in the future
  As an RTE
  I need the ability to add sprints according to sprint/team prefixes

  Background:
    Given a Jira Scrum board

  Scenario: Add several sprints using existing sprint prefixes
    Given the board only has the following sprints:
      | comment                 | name                   | length | start_date              | state  |
      | none added since closed | Food_Supply_25.1.3     | 2-week | 2025-02-01 11:00:00 UTC | closed |
      | "sprints                | Food_Delivery_25.1.4   | 4-day  | 2025-02-01 11:00:00 UTC | future |
      | expected to be          | Food_Market_25.2.1     | 3-week | 2025-02-01 11:00:00 UTC | active |
      | added"                  | Food_Restaurant_25.2.1 | 4-week | 2025-02-21 11:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sprint-add=25.3.1,4`
    Then afterwards the board only has the following sprints:
      | name                   | start_date              | state  |
      | Food_Supply_25.1.3     | 2025-02-01 11:00:00 UTC | closed |
      | Food_Delivery_25.1.4   | 2025-02-01 11:00:00 UTC | future |
      | Food_Delivery_25.3.1   | 2025-02-05 11:00:00 UTC | future |
      | Food_Delivery_25.3.2   | 2025-02-09 11:00:00 UTC | future |
      | Food_Delivery_25.3.3   | 2025-02-13 11:00:00 UTC | future |
      | Food_Delivery_25.3.4   | 2025-02-17 11:00:00 UTC | future |
      | Food_Market_25.2.1     | 2025-02-01 11:00:00 UTC | active |
      | Food_Market_25.3.1     | 2025-02-22 11:00:00 UTC | future |
      | Food_Market_25.3.2     | 2025-03-15 11:00:00 UTC | future |
      | Food_Market_25.3.3     | 2025-04-05 11:00:00 UTC | future |
      | Food_Market_25.3.4     | 2025-04-26 11:00:00 UTC | future |
      | Food_Restaurant_25.2.1 | 2025-02-21 11:00:00 UTC | future |
      | Food_Restaurant_25.3.1 | 2025-03-21 11:00:00 UTC | future |
      | Food_Restaurant_25.3.2 | 2025-04-18 11:00:00 UTC | future |
      | Food_Restaurant_25.3.3 | 2025-05-16 11:00:00 UTC | future |
      | Food_Restaurant_25.3.4 | 2025-06-13 11:00:00 UTC | future |

  Scenario: Add several planning interval sprints
    Given the board only has the following sprints:
      | comment                 | name                   | length | start_date              | state  |
      | none added since closed | Food_Supply_25.1.3     | 2-week | 2025-02-01 11:00:00 UTC | closed |
      | "sprints                | Food_Delivery_25.1.4   | 4-day  | 2025-02-01 11:00:00 UTC | future |
      | expected to be          | Food_Market_25.2.1     | 3-week | 2025-02-01 11:00:00 UTC | active |
      | added"                  | Food_Restaurant_25.2.1 | 4-week | 2025-02-21 11:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sa=25.2.2,3  --sa=25.3.1,4  --sa=25.4.1,5`
    Then afterwards the board only has the following sprints:
      | name                   | start_date              | state  |
      | Food_Supply_25.1.3     | 2025-02-01 11:00:00 UTC | closed |
      | Food_Delivery_25.1.4   | 2025-02-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.2   | 2025-02-05 11:00:00 UTC | future |
      | Food_Delivery_25.2.3   | 2025-02-09 11:00:00 UTC | future |
      | Food_Delivery_25.2.4   | 2025-02-13 11:00:00 UTC | future |
      | Food_Delivery_25.3.1   | 2025-02-17 11:00:00 UTC | future |
      | Food_Delivery_25.3.2   | 2025-02-21 11:00:00 UTC | future |
      | Food_Delivery_25.3.3   | 2025-02-25 11:00:00 UTC | future |
      | Food_Delivery_25.3.4   | 2025-03-01 11:00:00 UTC | future |
      | Food_Delivery_25.4.1   | 2025-03-05 11:00:00 UTC | future |
      | Food_Delivery_25.4.2   | 2025-03-09 11:00:00 UTC | future |
      | Food_Delivery_25.4.3   | 2025-03-13 11:00:00 UTC | future |
      | Food_Delivery_25.4.4   | 2025-03-17 11:00:00 UTC | future |
      | Food_Delivery_25.4.5   | 2025-03-21 11:00:00 UTC | future |
      | Food_Market_25.2.1     | 2025-02-01 11:00:00 UTC | active |
      | Food_Market_25.2.2     | 2025-02-22 11:00:00 UTC | future |
      | Food_Market_25.2.3     | 2025-03-15 11:00:00 UTC | future |
      | Food_Market_25.2.4     | 2025-04-05 11:00:00 UTC | future |
      | Food_Market_25.3.1     | 2025-04-26 11:00:00 UTC | future |
      | Food_Market_25.3.2     | 2025-05-17 11:00:00 UTC | future |
      | Food_Market_25.3.3     | 2025-06-07 11:00:00 UTC | future |
      | Food_Market_25.3.4     | 2025-06-28 11:00:00 UTC | future |
      | Food_Market_25.4.1     | 2025-07-19 11:00:00 UTC | future |
      | Food_Market_25.4.2     | 2025-08-09 11:00:00 UTC | future |
      | Food_Market_25.4.3     | 2025-08-30 11:00:00 UTC | future |
      | Food_Market_25.4.4     | 2025-09-20 11:00:00 UTC | future |
      | Food_Market_25.4.5     | 2025-10-11 11:00:00 UTC | future |
      | Food_Restaurant_25.2.1 | 2025-02-21 11:00:00 UTC | future |
      | Food_Restaurant_25.2.2 | 2025-03-21 11:00:00 UTC | future |
      | Food_Restaurant_25.2.3 | 2025-04-18 11:00:00 UTC | future |
      | Food_Restaurant_25.2.4 | 2025-05-16 11:00:00 UTC | future |
      | Food_Restaurant_25.3.1 | 2025-06-13 11:00:00 UTC | future |
      | Food_Restaurant_25.3.2 | 2025-07-11 11:00:00 UTC | future |
      | Food_Restaurant_25.3.3 | 2025-08-08 11:00:00 UTC | future |
      | Food_Restaurant_25.3.4 | 2025-09-05 11:00:00 UTC | future |
      | Food_Restaurant_25.4.1 | 2025-10-03 11:00:00 UTC | future |
      | Food_Restaurant_25.4.2 | 2025-10-31 11:00:00 UTC | future |
      | Food_Restaurant_25.4.3 | 2025-11-28 11:00:00 UTC | future |
      | Food_Restaurant_25.4.4 | 2025-12-26 11:00:00 UTC | future |
      | Food_Restaurant_25.4.5 | 2026-01-23 11:00:00 UTC | future |

  Scenario: Adding sprints is not creating duplicates or ones anterior to last sprints of prefixes
    Given the board only has the following sprints:
      | comment                                              | name                   | length | start_date              | state  |
      | none added since closed                              | Food_Supply_25.1.3     | 2-week | 2025-02-01 11:00:00 UTC | closed |
      | all sprints added                                    | Food_Delivery_25.1.4   | 4-day  | 2025-02-01 11:00:00 UTC | future |
      | the last 3 added since the first already exist       | Food_Market_25.2.1     | 3-week | 2025-02-01 11:00:00 UTC | active |
      | none added because would be anterior existing sprint | Food_Restaurant_25.3.1 | 4-week | 2025-02-21 11:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sa=25.2.1,4`
    Then afterwards the board only has the following sprints:
      | name                   | start_date              | state  |
      | Food_Supply_25.1.3     | 2025-02-01 11:00:00 UTC | closed |
      | Food_Delivery_25.1.4   | 2025-02-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.1   | 2025-02-05 11:00:00 UTC | future |
      | Food_Delivery_25.2.2   | 2025-02-09 11:00:00 UTC | future |
      | Food_Delivery_25.2.3   | 2025-02-13 11:00:00 UTC | future |
      | Food_Delivery_25.2.4   | 2025-02-17 11:00:00 UTC | future |
      | Food_Market_25.2.1     | 2025-02-01 11:00:00 UTC | active |
      | Food_Market_25.2.2     | 2025-02-22 11:00:00 UTC | future |
      | Food_Market_25.2.3     | 2025-03-15 11:00:00 UTC | future |
      | Food_Market_25.2.4     | 2025-04-05 11:00:00 UTC | future |
      | Food_Restaurant_25.3.1 | 2025-02-21 11:00:00 UTC | future |
