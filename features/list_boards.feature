Feature: List Boards
  # TODO: add Supply and Delivery boards so they are listed and checked
  Scenario: List Boards
    When I successfully run `jira-auto-tool --board-list`
    Then the stdout should contain:
    """
    +-------------+-----------------------+---------------------------------------------------------------------------------+
    |                                                        Boards                                                         |
    +-------------+-----------------------+---------------------------------------------------------------------------------+
    | Project Key | Name                  | Board UI URL                                                                    |
    +-------------+-----------------------+---------------------------------------------------------------------------------+
    """
