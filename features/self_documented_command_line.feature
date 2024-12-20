Feature: Self Documented Command Line

  Scenario Outline: The tool provides a help summary
    When I run `jira-auto-tool <arguments>`
    Then the output should contain:
       """
Usage: jira-auto-tool [options]*

       """
    Examples:
      | explanation					                | arguments |
      | no argument should print the help message 	|           |
      | help flag long version 	     	  		    | --help    |
      | help flag short version 			        | -h        |
     