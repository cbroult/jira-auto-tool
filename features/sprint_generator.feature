Feature: Sprint Configuration Generator\
  In order to prepare for PI Plannning
  As an RTE
  I need to generate the configuraiton of the PI sprints

  Scenario:
    When I run `jira-sprint-tool --board-name="CD Board" --sprint-generator-start-date-time="2025-01-09 11:00" --sprint-generator-iteration-prefix=EAT_DwRep_ --sprint-generator-iteration-index-start=2 --sprint-generator-iteration-length-in-days=14 --sprint-generator-iteration-count=6`
    Then the output should contain:
       """
EAT_DwRep_25.1.2,2025-01-09T11:00:00,2025-01-23T11:00:00
EAT_DwRep_25.1.3,2025-01-23T11:00:00,2025-02-06T11:00:00
EAT_DwRep_25.1.4,2025-02-06T11:00:00,2025-02-20T11:00:00
EAT_DwRep_25.1.5,2025-02-20T11:00:00,2025-01-23T11:00:00
EAT_DwRep_25.1.6,2025-01-09T11:00:00,2025-01-23T11:00:00
       """
       