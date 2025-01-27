Feature: List Project Ticket Fields
  In order to understand the project ticket expectations
  As a Jira user
  I need to list the project ticket fields

  Scenario: List Project Ticket Fields
    Given a Jira project
    When I succesfully run `jira-auto-tool --project-field-list`
    Then the output should match:
      """
      \| Project Key \| Ticket Type \| Field Name \| Field Type \|
      """
