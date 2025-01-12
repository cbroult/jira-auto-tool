Feature: List Boards

  @announce-stdout
  @announce-stderr
  @announce-command
  Scenario: List Boards
    When I successfully run `jira-auto-tool --board-list`
    Then the stdout should contain:
    """
    +-------------+-----------------------------+--------------------------------------------------------------------------------+
    |                                                           Boards                                                           |
    +-------------+-----------------------------+--------------------------------------------------------------------------------+
    | Project Key | Name                        | Board UI URL                                                                   |
    +-------------+-----------------------------+--------------------------------------------------------------------------------+
    """
