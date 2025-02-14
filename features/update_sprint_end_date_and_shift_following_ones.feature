Feature: Rename sprints
  In order to adjust the end date of a sprint to cope with specific periods like year end
  As a team member
  I need the ability to update the end date of a sprint and shift the following sprints

  Background:
    Given a Jira Scrum board

  Scenario: Adjust the end of a sprint and shift the following ones so there are no gaps
    Given the board only has the following sprints:
      | comment       | name                   | length | start_date              | state  |
      | "no           | Food_Supply_25.1.2     | 2-week | 2025-01-07 11:00:00 UTC | closed |
      | change        | Food_Supply_25.1.3     | 2-week | 2025-01-21 11:00:00 UTC | closed |
      | since         | Food_Supply_25.1.4     | 2-week | 2025-02-04 11:00:00 UTC | closed |
      | closed"       | Food_Supply_25.1.5     | 2-week | 2025-02-18 11:00:00 UTC | closed |
      |               | Food_Delivery_25.1.2   | 2-week | 2025-01-07 11:00:00 UTC | future |
      |               | Food_Delivery_25.1.3   | 2-week | 2025-01-21 11:00:00 UTC | future |
      |               | Food_Delivery_25.1.4   | 2-week | 2025-02-04 11:00:00 UTC | future |
      | new end date  | Food_Delivery_25.1.5   | 2-week | 2025-02-18 11:00:00 UTC | future |
      | shifted       | Food_Delivery_25.2.1   | 2-week | 2025-03-04 11:00:00 UTC | future |
      | idem          | Food_Delivery_25.2.2   | 2-week | 2025-03-18 11:00:00 UTC | future |
      | idem          | Food_Delivery_25.2.3   | 2-week | 2025-04-01 11:00:00 UTC | future |
      | idem          | Food_Delivery_25.2.4   | 2-week | 2025-04-15 11:00:00 UTC | future |
      | idem          | Food_Delivery_25.2.5   | 2-week | 2025-04-29 11:00:00 UTC | future |
      |               | Food_Restaurant_24.4.1 | 4-day  | 2025-01-07 11:00:00 UTC | future |
      | "last two     | Food_Restaurant_25.1.5 | 4-day  | 2025-01-18 11:00:00 UTC | future |
      | updated"      | Food_Restaurant_25.2.1 | 4-day  | 2025-04-01 11:00:00 UTC | future |
      | "no update    | Food_Market_25.2.5     | 4-day  | 2025-06-14 11:00:00 UTC | future |
      | since         | Food_Market_25.3.1     | 4-day  | 2025-07-07 11:00:00 UTC | future |
      | not matching" | Food_Market_25.3.2     | 4-day  | 2025-07-21 11:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sprint-update-end-date=25.1.5,"2025-02-25 16:00:00 UTC"`
    Then afterwards the board only has the following sprints:
      | name                   | start_date              | end_date                | state  |
      | Food_Supply_25.1.2     | 2025-01-07 11:00:00 UTC | 2025-01-21 11:00:00 UTC | closed |
      | Food_Supply_25.1.3     | 2025-01-21 11:00:00 UTC | 2025-02-04 11:00:00 UTC | closed |
      | Food_Supply_25.1.4     | 2025-02-04 11:00:00 UTC | 2025-02-18 11:00:00 UTC | closed |
      | Food_Supply_25.1.5     | 2025-02-18 11:00:00 UTC | 2025-03-04 11:00:00 UTC | closed |
      | Food_Delivery_25.1.2   | 2025-01-07 11:00:00 UTC | 2025-01-21 11:00:00 UTC | future |
      | Food_Delivery_25.1.3   | 2025-01-21 11:00:00 UTC | 2025-02-04 11:00:00 UTC | future |
      | Food_Delivery_25.1.4   | 2025-02-04 11:00:00 UTC | 2025-02-18 11:00:00 UTC | future |
      | Food_Delivery_25.1.5   | 2025-02-18 11:00:00 UTC | 2025-02-25 16:00:00 UTC | future |
      | Food_Delivery_25.2.1   | 2025-02-25 16:00:00 UTC | 2025-03-11 16:00:00 UTC | future |
      | Food_Delivery_25.2.2   | 2025-03-11 16:00:00 UTC | 2025-03-25 16:00:00 UTC | future |
      | Food_Delivery_25.2.3   | 2025-03-25 16:00:00 UTC | 2025-04-08 16:00:00 UTC | future |
      | Food_Delivery_25.2.4   | 2025-04-08 16:00:00 UTC | 2025-04-22 16:00:00 UTC | future |
      | Food_Delivery_25.2.5   | 2025-04-22 16:00:00 UTC | 2025-05-06 16:00:00 UTC | future |
      | Food_Restaurant_24.4.1 | 2025-01-07 11:00:00 UTC | 2025-01-11 11:00:00 UTC | future |
      | Food_Restaurant_25.1.5 | 2025-01-18 11:00:00 UTC | 2025-02-25 16:00:00 UTC | future |
      | Food_Restaurant_25.2.1 | 2025-02-25 16:00:00 UTC | 2025-03-01 16:00:00 UTC | future |
      | Food_Market_25.2.5     | 2025-06-14 11:00:00 UTC | 2025-06-18 11:00:00 UTC | future |
      | Food_Market_25.3.1     | 2025-07-07 11:00:00 UTC | 2025-07-11 11:00:00 UTC | future |
      | Food_Market_25.3.2     | 2025-07-21 11:00:00 UTC | 2025-07-25 11:00:00 UTC | future |
