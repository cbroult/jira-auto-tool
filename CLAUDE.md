# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle install                          # install dependencies
bundle exec rake verify                 # run all checks (rubocop + spec + cucumber)
bundle exec rspec                       # run all unit tests
bundle exec rspec spec/path/to/file_spec.rb  # run a single spec file
bundle exec cucumber                    # run all integration tests
bundle exec cucumber features/foo.feature   # run a single feature
bundle exec guard                       # continuous testing while developing
bundle exec rake rubocop                # lint (with autocorrect)
bundle exec rake version:bump[patch]    # bump version (major|minor|patch)
bundle exec rake release                # release to rubygems.org
```

Cucumber profiles: `default` (pretty output), `guard` (rerun on failure), `rake` (progress, skips `@wip`). Tags `@in-specification` are excluded from all runs; `@wip` only from `rake`.

## Architecture

`Jira::Auto::Tool` (`lib/jira/auto/tool.rb`) is the central orchestrator. All configuration flows through it: environment variables are read via `EnvironmentBasedValue` and optionally overridden by a YAML config at `~/.config/jira-auto-tool/jira-auto-tool.config.yml`.

### Key layers

**CLI → Performer → Tool → RequestBuilder → Jira API**

- **CLI** (`bin/jira-auto-tool`): OptionParser-based. Options are registered in `*/options.rb` files under each controller/performer namespace.
- **Controllers** (`BoardController`, `SprintController`, `FieldController`): Orchestrate reads and present tabular output via `terminal-table`.
- **Performers** (`lib/jira/auto/tool/performer/`): Encapsulate multi-sprint write operations: `SprintRenamer`, `QuarterlySprintRenamer`, `SprintEndDateUpdater`, `SprintTimeInDatesAligner`, `PlanningIncrementSprintCreator`.
- **RequestBuilder** (`lib/jira/auto/tool/request_builder/`): Abstract base for Jira REST calls. Concrete subclasses implement `http_verb`, `request_path`, `request_payload`, `expected_response`, and message prefix methods.
- **RateLimitedJiraClient**: Subclasses `JIRA::Client`. Two implementations: `InProcessBased` (default) and `RedisBased`. Selected via the `JAT_RATE_LIMIT_IMPLEMENTATION` env var.

### Sprint naming convention

Sprints must match `{prefix}_{YY}.{quarter}.{index}` (e.g., `Food_Delivery_25.3.1`). The regex lives in `Sprint::Name::SPRINT_NAME_REGEX`. Sprints that don't match are ignored with a warning.

### Board caching

`Board::Cache` persists board lists for one day to avoid hammering large Jira instances. Clear it with `Board::Cache.new(tool).clear`.

### Environment-based configuration

`EnvironmentBasedValue` dynamically generates reader, predicate (`_defined?`), writer, and `_when_defined_else` methods for every env var listed in `Tool::ENVIRONMENT_BASED_VALUE_SYMBOLS`. Config file values take precedence over env vars.

### Testing approach

- **Unit tests** (`spec/`): RSpec with `verify_partial_doubles`, `expect` syntax only. Coverage enforced at ≥90% overall / ≥80% per file via SimpleCov. Use `jira_resource_double` (defined in `spec_helper.rb`) instead of `double` for JIRA resource objects.
- **Integration tests** (`features/`): Cucumber + Aruba, connecting to a real Jira sandbox. Each scenario resets state by deleting all sprints and tickets from the board and clearing the board cache in `Before` hooks.
