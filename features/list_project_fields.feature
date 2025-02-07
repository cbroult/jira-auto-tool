Feature: List Project Ticket Fields
  In order to understand the project ticket expectations
  As a Jira user
  I need to list the project ticket fields

  Scenario: List Project Ticket Fields
    Given a Jira project
    When I successfully run `jira-auto-tool --project-field-list`
    Then the output should contain:
      """
      +-------------+-------------------+---------------------+------------+---------------------------------------------------------------------------------------------------------------------+
      | Ticket Type | Field Key         | Field Name          | Field Type | Allowed Values                                                                                                      |
      +-------------+-------------------+---------------------+------------+---------------------------------------------------------------------------------------------------------------------+
      | Bug         | assignee          | Assignee            | user       | n/a                                                                                                                 |
      | Bug         | attachment        | Attachment          | array      | n/a                                                                                                                 |
      | Bug         | components        | Components          | array      | []                                                                                                                  |
      | Bug         | customfield_10001 | Team                | team       | n/a                                                                                                                 |
      | Bug         | customfield_10020 | Sprint              | array      | n/a                                                                                                                 |
      | Bug         | customfield_10081 | Expected Start      | date       | n/a                                                                                                                 |
      | Bug         | customfield_10082 | Implementation Team | option     | ["A16 CRM (10044)", "A16 E2E-Test (10045)", "A16 Logistic (10048)", "A16 Platform (10046)", "A16 Sys-Team (10047)"] |
      | Bug         | description       | Description         | string     | n/a                                                                                                                 |
      """
    Then the output should contain:
      """
      | Epic        | assignee          | Assignee            | user       | n/a                                                                                                                 |
      | Epic        | attachment        | Attachment          | array      | n/a                                                                                                                 |
      | Epic        | components        | Components          | array      | []                                                                                                                  |
      | Epic        | customfield_10001 | Team                | team       | n/a                                                                                                                 |
      | Epic        | customfield_10020 | Sprint              | array      | n/a                                                                                                                 |
      | Epic        | customfield_10081 | Expected Start      | date       | n/a                                                                                                                 |
      | Epic        | customfield_10082 | Implementation Team | option     | ["A16 CRM (10044)", "A16 E2E-Test (10045)", "A16 Logistic (10048)", "A16 Platform (10046)", "A16 Sys-Team (10047)"] |
      | Epic        | description       | Description         | string     | n/a                                                                                                                 |
      | Epic        | fixVersions       | Fix versions        | array      | []                                                                                                                  |
      | Epic        | issuelinks        | Linked Issues       | array      | n/a                                                                                                                 |
      | Epic        | issuetype         | Issue Type          | issuetype  | ["Epic (10000)"]                                                                                                    |
      | Epic        | labels            | Labels              | array      | n/a                                                                                                                 |
      | Epic        | priority          | Priority            | priority   | ["Highest (1)", "High (2)", "Medium (3)", "Low (4)", "Lowest (5)"]                                                  |
      """
    Then the output should contain:
      """
      | Story       | assignee          | Assignee            | user       | n/a                                                                                                                 |
      | Story       | attachment        | Attachment          | array      | n/a                                                                                                                 |
      | Story       | components        | Components          | array      | []                                                                                                                  |
      | Story       | customfield_10001 | Team                | team       | n/a                                                                                                                 |
      | Story       | customfield_10020 | Sprint              | array      | n/a                                                                                                                 |
      | Story       | customfield_10081 | Expected Start      | date       | n/a                                                                                                                 |
      | Story       | customfield_10082 | Implementation Team | option     | ["A16 CRM (10044)", "A16 E2E-Test (10045)", "A16 Logistic (10048)", "A16 Platform (10046)", "A16 Sys-Team (10047)"] |
      | Story       | description       | Description         | string     | n/a                                                                                                                 |
      | Story       | fixVersions       | Fix versions        | array      | []                                                                                                                  |
      | Story       | issuelinks        | Linked Issues       | array      | n/a                                                                                                                 |
      | Story       | issuetype         | Issue Type          | issuetype  | ["Story (10003)"]                                                                                                   |
      | Story       | labels            | Labels              | array      | n/a                                                                                                                 |
      | Story       | parent            | Parent              | issuelink  | n/a                                                                                                                 |
      | Story       | priority          | Priority            | priority   | ["Highest (1)", "High (2)", "Medium (3)", "Low (4)", "Lowest (5)"]                                                  |
      """
    Then the output should contain:
      """
      | Sub-task    | assignee          | Assignee            | user       | n/a                                                                                                                 |
      | Sub-task    | attachment        | Attachment          | array      | n/a                                                                                                                 |
      | Sub-task    | components        | Components          | array      | []                                                                                                                  |
      | Sub-task    | customfield_10001 | Team                | team       | n/a                                                                                                                 |
      | Sub-task    | customfield_10020 | Sprint              | array      | n/a                                                                                                                 |
      | Sub-task    | customfield_10081 | Expected Start      | date       | n/a                                                                                                                 |
      | Sub-task    | customfield_10082 | Implementation Team | option     | ["A16 CRM (10044)", "A16 E2E-Test (10045)", "A16 Logistic (10048)", "A16 Platform (10046)", "A16 Sys-Team (10047)"] |
      | Sub-task    | description       | Description         | string     | n/a                                                                                                                 |
      | Sub-task    | fixVersions       | Fix versions        | array      | []                                                                                                                  |
      | Sub-task    | issuelinks        | Linked Issues       | array      | n/a                                                                                                                 |
      | Sub-task    | issuetype         | Issue Type          | issuetype  | ["Sub-task (10006)"]                                                                                                |
      | Sub-task    | labels            | Labels              | array      | n/a                                                                                                                 |
      | Sub-task    | parent            | Parent              | issuelink  | n/a                                                                                                                 |
      | Sub-task    | priority          | Priority            | priority   | ["Highest (1)", "High (2)", "Medium (3)", "Low (4)", "Lowest (5)"]                                                  |
      """
    Then the output should contain:
      """
      | Task        | assignee          | Assignee            | user       | n/a                                                                                                                 |
      | Task        | attachment        | Attachment          | array      | n/a                                                                                                                 |
      | Task        | components        | Components          | array      | []                                                                                                                  |
      | Task        | customfield_10001 | Team                | team       | n/a                                                                                                                 |
      | Task        | customfield_10020 | Sprint              | array      | n/a                                                                                                                 |
      | Task        | customfield_10081 | Expected Start      | date       | n/a                                                                                                                 |
      | Task        | customfield_10082 | Implementation Team | option     | ["A16 CRM (10044)", "A16 E2E-Test (10045)", "A16 Logistic (10048)", "A16 Platform (10046)", "A16 Sys-Team (10047)"] |
      | Task        | description       | Description         | string     | n/a                                                                                                                 |
      | Task        | fixVersions       | Fix versions        | array      | []                                                                                                                  |
      | Task        | issuelinks        | Linked Issues       | array      | n/a                                                                                                                 |
      | Task        | issuetype         | Issue Type          | issuetype  | ["Task (10005)"]                                                                                                    |
      | Task        | labels            | Labels              | array      | n/a                                                                                                                 |
      | Task        | parent            | Parent              | issuelink  | n/a                                                                                                                 |
      | Task        | priority          | Priority            | priority   | ["Highest (1)", "High (2)", "Medium (3)", "Low (4)", "Lowest (5)"]                                                  |
      """
