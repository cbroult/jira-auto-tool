# Jira::Sprint::Tool

![Main Workflow - main branch](https://github.com/cbroult/jira-auto-tool/actions/workflows/main.yml/badge.svg?branch=main&label=Ruby%20-%20main%20branch)
![Main Workflow - all branches](https://github.com/cbroult/jira-auto-tool/actions/workflows/main.yml/badge.svg?label=Ruby%20-%20all%20branches)

****
The purpose of this tool is to make it easier to make adjustments to the sprints of multiple teams.
See the [feature files](./features) for some behavior examples.

## Table of Contents

- [Principles](#principles)
- [Installation](#installation)
- [Setup](#setup)
- [Usage](#usage)
    - [Warning](#warning)
    - [Add Sprints](#add-sprints)
    - [Adjusting The End Date Of Sprints](#adjusting-the-end-date-of-sprints)
    - [Align Time In Sprint Dates](#align-time-in-sprint-dates)
    - [List Sprints](#list-sprints)
    - [List Sprint Prefixes (Teams)](#list-sprint-prefixes-teams)
    - [Rename Sprints](#rename-sprints)
    - [Team Sprint Mapping](#team-sprint-mapping)
    - [Team Ticket Sprint Dispatching](#team-ticket-sprint-dispatching)
- [Development](#development)
    - [Install Dependencies](#install-dependencies)
    - [Continuous Testing While Making Changes](#continuous-testing-while-making-changes)
    - [Experiment Using An Interactive Prompt](#experiment-using-an-interactive-prompt)
    - [Install Locally](#install-locally)
    - [Release](#release)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Principles

Following a convention over configuration approach:
* All Scrum boards from the Jira instance are scanned to identify the ones matching the search criteria 
(the list is [cached for a day for performance reasons](./features/cache_boards.feature) to deal with Jira 
instances having thousands of boards);
* For each board, only the unclosed sprints are considered;
* Sprint manipulations only apply to those sprints whose names match the following format: `sprint_prefix_25.4.3`
* [Creating new sprints](./features/create_sprints_using_existing_ones_as_reference.feature) 
will use the existing ones as a reference for the prefix and the length of the sprint.

## Installation

1. Install [Ruby](https://www.ruby-lang.org/en/downloads/).
1. Install the gem...
   * ... and add to the application's Gemfile by executing:

     ```bash
     bundle add jira-auto-tool
     ```
     
   * ... if bundler is not being used to manage dependencies, by executing:
     
     ```bash
     gem install jira-auto-tool
     ```

## Setup

1. Create an example configuration file
   ```bash
   jira-auto-tool --env-setup
   ```
2. Adjust the file to your context. 

The following environment variables have to be set to use this tool. **Except** for the `JIRA_API_TOKEN` that should 
be done via the configuration file.

Some explanations:

- `JIRA_USERNAME` - Your Jira account username (e.g., "user@company.com").
- `JIRA_API_TOKEN` - Your Jira API authentication token.
- `JIRA_SITE_URL` - Base URL of your Jira instance (e.g., "https://your-domain.atlassian.net").
- `JIRA_BOARD_NAME` - Name of the Jira board to work with (e.g., "Team Board").
- `JIRA_BOARD_NAME_REGEX` - Regular expression pattern to match board names (e.g., "ART 16|unconventional board name").
- `JIRA_PROJECT_KEY` - Key of the Jira project (e.g., "PROJ").
- `JAT_TICKETS_FOR_TEAM_SPRINT_TICKET_DISPATCHER_JQL` - Query to identify tickets requiring sprint dispatching 
(e.g., "project = PROJ AND Sprint IS EMPTY"). 
See [Team Ticket Dispatching](./features/assign_tickets_to_team_sprints.feature).
- `JIRA_SPRINT_FIELD_NAME` - Custom field name for Sprint (e.g., "Sprint").
- `IMPLEMENTATION_TEAM_FIELD_NAME` - Custom field name for storing team assignments (e.g., "Implementation Team").

Optional environment variables:

- `ART_SPRINT_REGEX` - Can be used to limit the sprints that are going to be manipulated (e.g., "ART-16|(4\.1)"). 
See [sprint filtering](./features/sprint_filtering.feature).
- `JIRA_CONTEXT_PATH` - Context path for Jira instance (if needed typically "/jira").
- `JIRA_HTTP_DEBUG` - Enable HTTP debug logging (set to "true" or "false").
- `JAT_RATE_INTERVAL_IN_SECONDS` - Interval for rate limiting in seconds (e.g., "1").
- `JAT_RATE_LIMIT_PER_INTERVAL` - Rate limit for Jira API calls (e.g., "1") 
See [Control Jira HTTP request rate](./features/control_http_request_rate_limit.feature).

## Usage

* Use the tool integrated help: 
  ```bash
  jira-auto-tool --help
  ```
* Leverage the [specification by examples](./features) for a detailled understand of the features.
* Note that usually the long option names have a short version equivalent to reduce typing.

### Warning

1. You should familiarize yourself with this tool in a Jira sandbox project **before applying it to your context**.
   That can be done easily by [creating a free Atlassian account](https://www.atlassian.com/software)
   like it has been done to document [this tool features](./features) using executable specifications.

1. Remember that you are **not allowed** to use confidential/sensitive information when familiarizing with this tool
   in such a cloud sandbox. Though, if the sandbox belongs to the target context
   (e.g., sandbox project on the client Jira instance) you can experiment with the parameters you intend to use later.

Below are a few examples.

### Add Sprints

The following is going to [add sprints](./features/create_sprints_using_existing_ones_as_reference.feature) 
`sprint_prefix_25.4.3` until `sprint_prefix_25.4.6` 
to the teams respective sprint prefixes. 
```bash
jira-auto-tool --sprint-add=25.4.3,4
```

### Adjusting The End Date Of Sprints

The following is going to 
[adjust the end date of sprints](./features/update_sprint_end_date_and_shift_following_ones.feature) 
named `sprint_prefix_25.1.5` and shift the subsequent ones by adjust their start and end dates: 
```bash
jira-auto-tool --sprint-update-end-date=25.1.5,"2025-02-25 16:00:00 UTC"
```

### Align Time In Sprint Dates

````bash
jira-auto-tool --sprint-align-time-in-dates="14:15 UTC"
````

### List Sprints

```bash
jira-auto-tool --sprint-list
```

### List Sprint Prefixes (Teams)

```bash
jira-auto-tool --sprint-prefix-list
```

### Rename Sprints

```bash
jira-auto-tool --sprint-rename=25.3.5,25.4.1
```

### Team Sprint Mapping

```bash
jira-auto-tool --team-sprint-mapping-list
```

### Team Ticket Sprint Dispatching

```bash
jira-auto-tool --team-sprint-mapping-dispatch-tickets
```

## Development

After checking out this repository.

### Install Dependencies

```bash
bundle install
```

### Continuous Testing While Making Changes

```bash
bundle exec guard
```

### Experiment Using An Interactive Prompt

```bash
bin/console
```
 
### Install Locally

To install this gem onto your local machine, run `bundle exec rake install`.

### Release

1. Bump the gem version:
   ```bash
   bundle exec rake version:bump[{major|minor|patch}]   
   ```
2. Release the version to [rubygems.org](https://rubygems.org):
   ```bash
   bundle exec rake release
   ```
   which will:
   * create a git tag for the version
   * push git commits and the created tag
   * push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cbroult/jira-auto-tool. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/jira-auto-tool/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Jira::Sprint::Tool project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/jira-auto-tool/blob/master/CODE_OF_CONDUCT.md).
