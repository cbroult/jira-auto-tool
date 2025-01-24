@in-specification
Feature: Rename sprints
  In order to adjust the sprint names according to the convention and needs
  As a team member
  I need the ability to rename specific sprints and their followers

  Scenario: Rename sprint and followers
    Given a Jira project
    And a Jira Scrum board
    And the board only has the following sprints:
      | name | start_date | end_date |
    When I successfully run `jira-auto-tool --sprint-rename=25.1.5,25.2.1`
    Then the board only has the following sprints:
      | name | start_date | end_date |
