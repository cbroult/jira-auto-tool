@wip
Feature: Environment Configuration Management
  In order to avoid setting environment variables manually
  As a user of jira-auto-tool
  I want to be able to configure the tool using a configuration file

  Scenario: Creating the environment configuration file
    Given a file named "~/.config/jira-auto-tool/jira-auto-tool.env.yaml.erb" does not exist
    When I successfully run `jira-auto-tool --env-create-file`
    Then the output should match:
      """
      \s+INFO\s+Jira::Auto::Tool::EnvironmentLoader\s+:\s+Created\s+file\s.+/.config/jira-auto-tool/jira-auto-tool.env.yaml.erb
      _______________________________________________
      TODO: Adjust the configuration to your context!
      """
    And a file named "~/.config/jira-auto-tool/jira-auto-tool.env.yaml.erb" should contain exactly:
      """
      ---
      <%
        project_key = "JATCIDEVLX"
        sprint_field_name = "Sprint"
        jira_username = "cbroult@yahoo.com"
      %>
      ##JIRA_API_TOKEN: WARNING - it is recommended to set the value directly as an environment variable
      ART_SPRINT_REGEX:
      DISABLE_COVERAGE: true
      EXPECTED_START_DATE_FIELD_NAME: Expected Start
      IMPLEMENTATION_TEAM_FIELD_NAME: "Implementation Team"
      JAT_RATE_INTERVAL_IN_SECONDS:
      JAT_RATE_LIMIT_IMPLEMENTATION:
      JAT_RATE_LIMIT_PER_INTERVAL:
      JAT_TICKETS_FOR_TEAM_SPRINT_TICKET_DISPATCHER_JQL: "project = <%= project_key %> AND <%= sprint_field_name %> IS EMPTY"
      # JIRA_BOARD_NAME: "<<<Name of one board if the project>>>"
      JIRA_BOARD_NAME: "<%= project_key %> - Delivery"
      JIRA_BOARD_NAME_REGEX: "<%= project_key %>|ART 16|unconventional board name"
      #JIRA_CONTEXT_PATH: /jira
      JIRA_CONTEXT_PATH:
      JIRA_HTTP_DEBUG:
      JIRA_PROJECT_KEY: <%= project_key %>
      JIRA_SITE_URL: http://cbroult.atlassian.net:443/
      JIRA_SPRINT_FIELD_NAME: "<%= sprint_field_name %>"
      JIRA_USERNAME: <%= jira_username %>

      <%
        message = "TODO: set the values specific to your context and remove this part of the file"
        log.error { message  }
        raise message
      %>
      """


  Scenario: Not overriding an existing environment configuration file
    Given a file named "~/.config/jira-auto-tool/jira-auto-tool.env.yaml.erb" with:
      """
      ---
      JIRA_TOKEN: 'a dummy token'
      """
    When I run `jira-auto-tool --env-create-file`
    Then it should fail matching:
      """
      ERROR\s+Jira::Auto::Tool::EnvironmentLoader\s+:\s+Not\s+overriding\s+existing\s+.+/.config/jira-auto-tool/jira-auto-tool.env.yaml.erb
      ______________________________________________
      Please remove first before running this again!
      """

  Scenario: Tool successfully loads the config
    Given a file named "jira-auto-tool.env.yaml.erb" with:
      """
      ---
      <%
        jira_username = "user@jira.instance.com"
        project_key = 'PROJ'
        sprint_field_name = 'Sprint'
      %>

      ART_SPRINT_REGEX:
      EXPECTED_START_DATE_FIELD_NAME: Expected Start
      IMPLEMENTATION_TEAM_FIELD_NAME: "Implementation Team"
      JAT_RATE_INTERVAL_IN_SECONDS:
      JAT_RATE_LIMIT_IMPLEMENTATION:
      JAT_RATE_LIMIT_PER_INTERVAL:
      JAT_TICKETS_FOR_TEAM_SPRINT_TICKET_DISPATCHER_JQL: "project = <%= project_key %> AND <%= sprint_field_name %> IS EMPTY"
      JIRA_API_TOKEN: "current API TOKEN"
      JIRA_BOARD_NAME: "Team Board"
      JIRA_BOARD_NAME_REGEX: "ART 16|unconventional board name"
      JIRA_CONTEXT_PATH: /jira
      JIRA_HTTP_DEBUG:
      JIRA_PROJECT_KEY: <%= project_key %>
      JIRA_SITE_URL: "<%= 'https://example.atlassian.net' %>"
      JIRA_SPRINT_FIELD_NAME: "<%= sprint_field_name %>"
      JIRA_USERNAME: "<%= jira_username %>"
      """
    When I successfully run `jira-auto-tool --env-list`
    Then the output should contain exactly:
      """
      Using configuration from ./jira-auto-tool.env.yaml.erb
+---------------------------------------------------+------------------------------------+
| Name                                              | Value                              |
+---------------------------------------------------+------------------------------------+
| ART_SPRINT_REGEX                                  |                                    |
| EXPECTED_START_DATE_FIELD_NAME                    | Expected Start                     |
| IMPLEMENTATION_TEAM_FIELD_NAME                    | Implementation Team                |
| JAT_RATE_INTERVAL_IN_SECONDS                      |                                    |
| JAT_RATE_LIMIT_IMPLEMENTATION                     |                                    |
| JAT_RATE_LIMIT_PER_INTERVAL                       |                                    |
| JAT_TICKETS_FOR_TEAM_SPRINT_TICKET_DISPATCHER_JQL | project = PROJ AND Sprint IS EMPTY |
| JIRA_API_TOKEN                                    | current API TOKEN                  |
| JIRA_BOARD_NAME                                   | Team Board                         |
| JIRA_BOARD_NAME_REGEX                             | ART 16|unconventional board name   |
| JIRA_CONTEXT_PATH                                 | /jira                              |
| JIRA_HTTP_DEBUG                                   |                                    |
| JIRA_PROJECT_KEY                                  | PROJ                               |
| JIRA_SITE_URL                                     | https://example.atlassian.net      |
| JIRA_SPRINT_FIELD_NAME                            | Sprint                             |
| JIRA_USERNAME                                     | user@jira.instance.com             |
+---------------------------------------------------+------------------------------------+
      """

  Scenario: Tool looks first for configuration in the current directory
    Given a file named "./jira-auto-tool.env.yaml.erb" with:
      """
      ---
      JIRA_USERNAME: "current@company.com"
      JIRA_API_TOKEN: "current-token"
      JIRA_SITE_URL: "https://current.atlassian.net"
      """
    And a file named "~/.config/jira-auto-tool/jira-auto-tool.env.yaml.erb" with:
      """
      ---
      JIRA_USERNAME: "home@company.com"
      JIRA_API_TOKEN: "home-token"
      JIRA_SITE_URL: "https://home.atlassian.net"
      """
    When I successfully run `jira-auto-tool --env-list`
    Then the output should contain:
      """
      Using configuration from ./jira-auto-tool.env.yaml.erb
      """

  Scenario: Tool looks for home directory config folder when no config file in the current directory
    Given a file named "./jira-auto-tool.env.yaml.erb" does not exist
    And a file named "~/.config/jira-auto-tool/jira-auto-tool.env.yaml.erb" with:
      """
      JIRA_USERNAME: "home@company.com"
      JIRA_API_TOKEN: "home-token"
      JIRA_SITE_URL: "https://home.atlassian.net"
      """
    When I successfully run `jira-auto-tool --env-list`
    Then the output should match:
      """
      Using configuration from .+/.config/jira-auto-tool/jira-auto-tool.env.yaml.erb
      """

  Scenario: Tool uses the existing environment values if no config file found
    Given the following files should not exist:
      | ./jira-auto-tool.env.yaml.erb                        |
      | ~/.config/jira-auto-tool/jira-auto-tool.env.yaml.erb |
    And the following environment variables are set:
      | name           | value       |
      | JIRA_API_TOKEN | token-value |
    When I successfully run `jira-auto-tool --env-list`
    Then the output should match:
      """
      Only using the environment variables since neither of the following files exist:
      ./jira-auto-tool.env.yaml.erb
      .+/.config/jira-auto-tool/jira-auto-tool.env.yaml.erb
      """
    And the output should match:
      """
      JIRA_API_TOKEN\s+|token-value\s+
      """
