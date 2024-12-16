Feature: Self Documented Command Line

  Scenario Outline: The tool provides a help summary
    When I run `jira-sprint-tool <arguments>`
    Then the output should contain:
       """
Usage: jira-sprint-tool [options]*

       """
    Examples:
      | explanation					                | arguments |
      | no argument should print the help message 	|           |
      | help flag long version 	     	  		    | --help    |
      | help flag short version 			        | -h        |
     