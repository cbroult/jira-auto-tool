Feature: Rename sprints
  In order to adjust the sprint names according to the convention and needs
  As a team member
  I need the ability to rename specific sprints and their followers

  Scenario: Rename sprint and followers
    Given a Jira Scrum board
    And the board only has the following sprints:
      | name                   | length | start                   | state  |
      | Food_Supply_25.1.2     | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | Food_Supply_25.1.3     | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | Food_Supply_25.1.4     | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | Food_Supply_25.1.5     | 2-week | 2024-12-01 11:00:00 UTC | closed |
      | Food_Delivery_25.1.2   | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.3   | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.4   | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.5   | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.1   | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.2   | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.3   | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.4   | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.5   | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Restaurant_24.4.1 | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | Food_Restaurant_25.1.5 | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | Food_Restaurant_25.2.1 | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | Food_Market_25.2.5     | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | Food_Market_25.3.1     | 4-day  | 2024-12-01 11:00:00 UTC | future |
      | Food_Market_25.3.2     | 4-day  | 2024-12-01 11:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sprint-rename=25.1.5,25.2.1`
    Then afterwards the board only has the following sprints:
      | name                   | expected_start          | state  |
      | Food_Supply_25.1.2     | 2024-12-01 11:00:00 UTC | closed |
      | Food_Supply_25.1.3     | 2024-12-01 11:00:00 UTC | closed |
      | Food_Supply_25.1.4     | 2024-12-01 11:00:00 UTC | closed |
      | Food_Supply_25.1.5     | 2024-12-01 11:00:00 UTC | closed |
      | Food_Delivery_25.1.2   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.3   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.4   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.1   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.2   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.3   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.4   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.5   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.6   | 2024-12-01 11:00:00 UTC | future |
      | Food_Restaurant_24.4.1 | 2024-12-01 11:00:00 UTC | future |
      | Food_Restaurant_25.2.1 | 2024-12-01 11:00:00 UTC | future |
      | Food_Restaurant_25.2.2 | 2024-12-01 11:00:00 UTC | future |
      | Food_Market_25.2.5     | 2024-12-01 11:00:00 UTC | future |
      | Food_Market_25.3.1     | 2024-12-01 11:00:00 UTC | future |
      | Food_Market_25.3.2     | 2024-12-01 11:00:00 UTC | future |
