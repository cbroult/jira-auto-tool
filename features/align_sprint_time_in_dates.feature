Feature: Align sprint time in dates

  Scenario: Align time in sprints having start and end dates
    Given the board only has the following sprints:
      | comment                            | name                   | length | start                   | state  |
      | should be unchanged because closed | Food_Supply_25.1.5     | 2-week | 2024-12-01 01:00:00 UTC | closed |
      |                                    | Food_Delivery_25.1.2   | 2-week | 2024-12-14 18:00:00 UTC | future |
      |                                    | Food_Delivery_25.1.3   | 2-week | 2024-12-28 18:00:00 UTC | future |
      |                                    | Food_Restaurant_24.4.1 | 4-day  | 2024-12-05 23:00:00 UTC | future |
      |                                    | Food_Restaurant_25.1.5 | 4-day  | 2024-12-09 23:00:00 UTC | future |
      |                                    | Food_Market_25.3.2     | 4-day  | 2024-12-05 14:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sprint-align-time-in-dates="11:30 UTC"`
    Then afterwards the board only has the following sprints:
      | name                   | start_date              | end_date                | state  |
      | Food_Supply_25.1.5     | 2024-12-01 01:00:00 UTC | 2024-12-15 01:00:00 UTC | closed |
      | Food_Delivery_25.1.2   | 2024-12-14 11:30:00 UTC | 2024-12-28 11:30:00 UTC | future |
      | Food_Delivery_25.1.3   | 2024-12-28 11:30:00 UTC | 2025-01-11 11:30:00 UTC | future |
      | Food_Restaurant_24.4.1 | 2024-12-05 11:30:00 UTC | 2024-12-09 11:30:00 UTC | future |
      | Food_Restaurant_25.1.5 | 2024-12-09 11:30:00 UTC | 2024-12-13 11:30:00 UTC | future |
      | Food_Market_25.3.2     | 2024-12-05 11:30:00 UTC | 2024-12-09 11:30:00 UTC | future |

  @in-specification
  Scenario: Align time in sprints not having start and/or end dates
    Given the board only has the following sprints:
      | name                 | start_date              | end_date                | state  |
      | Food_Supply_25.1.5   |                         |                         | closed |
      | Food_Supply_25.1.5   |                         |                         | future |
      | Food_Delivery_25.1.2 | 2024-12-01 18:00:00 UTC |                         | future |
      | Food_Delivery_25.1.3 |                         | 2024-12-01 18:00:00 UTC | future |
    When I successfully run `jira-auto-tool --satid="14:15 UTC"`
    Then afterwards the board only has the following sprints:
      | name                 | start_date              | end_date                | state  |
      | Food_Supply_25.1.5   |                         |                         | closed |
      | Food_Supply_25.1.5   |                         |                         | future |
      | Food_Delivery_25.1.2 | 2024-12-01 14:15:00 UTC |                         | future |
      | Food_Delivery_25.1.3 |                         | 2024-12-01 14:15:00 UTC | future |
