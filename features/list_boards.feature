Feature: List Boards
  # TODO: add Supply and Delivery boards so they are listed and checked
  Scenario: List Boards
    When I successfully run `jira-auto-tool --board-list`
    Then the output should match:
    """
    \+------------------------------+----\+
    \|\s+Boards\s+\|
    \+----+-\+-----+-\+-------------+----\+
    \| Project Key\s+\| Name \s+\| Board UI URL\s+\|
    \+----+-\+-----+-\+-------------+----\+
    """
