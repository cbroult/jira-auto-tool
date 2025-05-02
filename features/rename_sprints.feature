Feature: Rename sprints
  In order to adjust the sprint names according to the convention and needs
  As a team member
  I need the ability to rename specific sprints and their followers

  Background:
    Given a Jira Scrum board

  Scenario: Push a sprint to the next planning interval and rename followers
    Given the board only has the following sprints:
      | name                   | length | start_date              | state  |
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
      | name                   | start_date              | state  |
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

  Scenario: Pull a sprint into the previous planning interval and rename followers
    Given the board only has the following sprints:
      | name                   | length | start_date              | state  |
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
    When I successfully run `jira-auto-tool --sr=25.2.1,25.1.6`
    Then afterwards the board only has the following sprints:
      | name                   | start_date              | state  |
      | Food_Supply_25.1.2     | 2024-12-01 11:00:00 UTC | closed |
      | Food_Supply_25.1.3     | 2024-12-01 11:00:00 UTC | closed |
      | Food_Supply_25.1.4     | 2024-12-01 11:00:00 UTC | closed |
      | Food_Supply_25.1.5     | 2024-12-01 11:00:00 UTC | closed |
      | Food_Delivery_25.1.2   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.3   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.4   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.5   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.6   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.7   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.8   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.9   | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.10  | 2024-12-01 11:00:00 UTC | future |
      | Food_Restaurant_24.4.1 | 2024-12-01 11:00:00 UTC | future |
      | Food_Restaurant_25.1.5 | 2024-12-01 11:00:00 UTC | future |
      | Food_Restaurant_25.1.6 | 2024-12-01 11:00:00 UTC | future |
      | Food_Market_25.2.5     | 2024-12-01 11:00:00 UTC | future |
      | Food_Market_25.3.1     | 2024-12-01 11:00:00 UTC | future |
      | Food_Market_25.3.2     | 2024-12-01 11:00:00 UTC | future |

  Scenario: Sprints beyond the planning interval of the sprint next to the first sprint to rename are also renamed
    Given the board only has the following sprints:
      | name                 | length | start_date              | state  |
      | Food_Delivery_25.1.2 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.3 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.4 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.5 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.1 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.2 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.3 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.4 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.5 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.3.1 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.3.4 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_26.1.1 | 2-week | 2024-12-01 11:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sprint-rename=25.1.5,25.2.1`
    Then afterwards the board only has the following sprints:
      | name                 | start_date              | state  |
      | Food_Delivery_25.1.2 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.3 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.1.4 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.1 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.2 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.3 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.4 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.5 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.6 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.7 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.8 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.9 | 2024-12-01 11:00:00 UTC | future |

  Scenario: Rename a sprint forward in a planning interval and all following sprints irrespective of their intervals
    Given the board only has the following sprints:
      | name                 | length | start_date              | state  |
      | Food_Delivery_25.1.5 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.1 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.2 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.3 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.4 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.5 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.3.1 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.3.4 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_26.1.1 | 2-week | 2024-12-01 11:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sprint-rename=25.2.2,25.2.10`
    Then afterwards the board only has the following sprints:
      | name                  | start_date              | state  |
      | Food_Delivery_25.1.5  | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.1  | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.10 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.11 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.12 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.13 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.14 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.15 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.16 | 2024-12-01 11:00:00 UTC | future |

  Scenario: Rename a sprint backward in a planning interval and all following sprints irrespective of their intervals
    Given the board only has the following sprints:
      | name                  | length | start_date              | state  |
      | Food_Delivery_25.1.5  | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.1  | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.10 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.11 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.12 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.13 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.3.1  | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.3.4  | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_26.1.1  | 2-week | 2024-12-01 11:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sprint-rename=25.2.10,25.2.2`
    Then afterwards the board only has the following sprints:
      | name                 | start_date              | state  |
      | Food_Delivery_25.1.5 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.1 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.2 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.3 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.4 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.5 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.6 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.7 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.8 | 2024-12-01 11:00:00 UTC | future |

  Scenario: Renaming several sprints having the same name eliminates the name duplicates
    Given the board only has the following sprints:
      | name                  | length | start_date              | state  |
      | Food_Delivery_25.1.5  | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.1  | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.10 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.10 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.10 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.10 | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.3.1  | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.3.4  | 2-week | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_26.1.1  | 2-week | 2024-12-01 11:00:00 UTC | future |
    When I successfully run `jira-auto-tool --sprint-rename=25.2.10,25.2.2`
    Then afterwards the board only has the following sprints:
      | name                 | start_date              | state  |
      | Food_Delivery_25.1.5 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.1 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.2 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.3 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.4 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.5 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.6 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.7 | 2024-12-01 11:00:00 UTC | future |
      | Food_Delivery_25.2.8 | 2024-12-01 11:00:00 UTC | future |
