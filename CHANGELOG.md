## [Unreleased]

## [1.3.0] - 2026-01-01 - Adding support for Jira API v3

- chore(dependencies): remove explicit Ruby version declaration in Gemfile
- chore(dependencies): update `Gemfile.lock` to include Ruby 3.4.8
- chore: add `.ruby-version` file with Ruby 3.4.8
- chore(build): make Ruby version dynamic based on `.ruby-version` file
- chore(gemspec): update required Ruby version to >= 3.4.8
- Bump jira-auto-tool to 1.3.0
- chore(dependencies): update `Gemfile.lock` to include `cgi` dependency for `jira-auto-tool`
- refactor(jira): enhance field handling, simplify method signatures, and add tests for improved API compatibility
- test(rate-limit): made the test more robust with data to query
- refactor(jira): improve compatibility across Jira API versions to support V3
- chore(gemspec): update required Ruby version to >= 3.4.7

## [1.2.2] - 2025-06-14

- Updated the gem versions

## [1.2.1] - 2025-05-10

- Update README and refine gemspec and code structure
- Add support for identifying and masking secret environment values
- Prevent creation of duplicate or anterior sprints.
- Update README with fixes and new example for sprint updates
- Improve error handling in EnvironmentLoader configuration parsing

## [1.2.0] - 2025-05-08

- Added support for in-process based Jira HTTP rate limiting to remove the need to setup Redis
- Rename rate limit environment variable for clarity
- Refactor README and example configs for clarity and consistency
- Refactor to rename and update rate-limited Jira client

## [1.1.3] - 2025-05-05

- Implementing disabling wrapper generation on Windows
- Updated the env example setting to reflect the dev environment setup
- Make sure the env values are set as strings
-     Exclude .bat files from gem executables
- Preventing the concurrent feature scenarios execution
- Fixed sprint filtering expectations

## [1.1.2] - 2025-05-04

- Add version bump task to streamline version management

## [1.1.1] - 2025-05-04

- Refactor and standardize environment variable handling
- Bumped the Gemfile.lock spec to jira-auto-tool (1.1.0)

## [1.1.0] - 2025-05-03

- Implemented the ability to configure the environment via a YAML.ERB file.

## [1.0.0] - 2025-05-02

- Bump jira-auto-tool to 1.0.0
- Update README with correct gem name for 1.0.0 installation
- Made checking --board-list output expectations more robust
- Remove @wip tag from rename_sprints feature file
- Update jira-auto-tool to v0.1.1 and downgrade Bundler version
- Update gemspec with valid push host and include spec and features folders

## [0.1.1] - 2025-05-02

- Add detailed instructions and usage examples to README
- Improved integrated help (--help) with examples and more visible sections.
- Update board cache expiry period from one hour to one day
- Add `rb-readline` dependency and more robust Windows-specific gems handling
- Add `rb-readline` dependency and more robust Windows-specific gems handling
- Update non rate limited example expectation to cope with longer execution times
- Refactor option handling and add HTTP debugging functionality.
- Refactor options handling into a dedicated module
- Fixing Rubocop warnings with the Gems not being in alphabetical order in the Gemfile
- Allow camelCase or snake_case parameters for request pagination.
- Handle duplicate sprint names during renaming process
- Improve Rakefile task configuration and annotate failing tests
- Add support for quarterly and general sprint renaming
- Refactor Jira client initialization to use helper method
- Update Gemfile.lock with new dependencies and platform adjustments
- Add `workflow_dispatch` trigger to GitHub Actions
- Update Gemfile.lock dependencies to latest compatible versions
- Refactor Jira sprint fetching to use reusable pagination helper.
- JAT-60 - Add `--quarterly-sprint-rename` to replace `--sprint-rename`
- JAT-60 - Refactor sprint methods to use quarterly-specific naming
- Upgraded all gems including uri to fix CVE-2025-27221
- JAT-56 - Caching all board attributes to avoid request them one by one
- JAT-55 - Made sure aruba is setup before using it in a hook
- JAT-55 - Aruba tests are running in the sandbox (no more HOME pollution)
- JAT-52 - Moved the cache to be stored in the config directory.
- JAT-49 - Implemented persisting configuration to a file
- Added sub sections in the command line help for readibility
- JAT-46 - Implemented filtered board caching
- GitHub Actions - Limiting execution to Ruby 3.4.2
- GitrHub Action - Fixing incorrect ruby matrix syntax
- JAT-38 - Implemented --sprint-add=25.3.1,4
- Gem package can build successfully
- Gem package can build successfully
- JAT-32 - Adjust the end date of a sprint
- Handling missing team and generating a warning when no sprint prefix associated to a team
- Fixed missed test due to terminal-table behavior change
- Updated the gem versions
- Add pre-push hook to run rake tasks
- Now using the team names/values associated to the tickets to map
- Fixed improper timezone specification
- Attempting to fix differing encoding while executing sprint_spec.rb tests
- Configured RSpec to use UTF-8 for internal and external encoding
- Attempting to fix differing encoding while executing sprint_spec.rb tests
- Attempting to fix differing encoding while executing sprint_spec.rb tests
- Add UTF-8 encoding to sprint_spec.rb
- Dealing with sprints missing dates while aligning time in dates
- Implemented aligning time in sprints having start and end dates
- Fixing syntax error in GitHub Action workflow
- Added missing JIRA_PROJECT_KEY
- Fixing syntax error in GitHub workflow
- Dynamically setting environment variables
- Implemented --project-field-list
- Adjustted the rate limiter maximal time
- Fixed the logic of NextNameGenerator#pulling_sprint_into_previous_planning_interval?
- Added KeepSameNameGenerator to further simplify the renaming logic
- Refactoring to simplify next name generation
- Adjusted rate limiting expectations
- Added more NextNameGenerator tests
- Removed TODO which was done in previous commit
- Refactored to simplify the renamer next name generation
- SprintRenamer: more scenarios and fixed saving name issue
- Implemented the SprintRenamer logic.
- Now accepting methods up to 20 lines
- --sprint-list now expects the sprints to be sorted
- Fixed matching the output of --sprint-prefix-list
- Request rate limiting environment variable driven and disabled by default.
- Added renaming sprint feature early draft
- Mocking board when testing the Tool class.
- Sprints appearing on several boards are only listed once.
- Fixed rate limiting by properly tracking each API call.
- Handling non convention compliant names for comparisons.
- project_ticket_creation_metadata_fetcher.rb Added an AI Assistant suggestion as commented out code
- Made the table header matching regex based
- Made sure that ./bin is the executable directory for the gem
- SprintController#sprints no longer returns sprint duplicates that could appear when the same sprint is visible on several boards
- Fixed running jira-auto-tool from another folder than the gem root
- Removed unnecessary JIRA::HttpClient patch
- Fix GitHub Actions misaligned expected board name and board name regex values
- Switched to using RateLimitedJiraClient
- Made the check of expected out --xx-list commands more robust
- Removed the duplicated board loading
- Fixed sprint filtering testing and ignoring closed ones
- Listing only unclosed sprints
- Added Sprint Id output when listing sprints
- HTTP rate limit to 1 request every 4 seconds
- Adjusted the JIRA board name to use in the GitHub Action
- Added the missing redis ports
- Waiting for redis to start
- Added the installation of the redis-cli
- Removed the explicit redis port information
- Redis values are defined at the global environment level
- Fixing the redis port variable use
- Fixed misalignment in GitHub Action definition
- Ignoring with a warning sprints not comforming to a format like ART_Team_25.1.2
- Rate limited the HTTP requests to one every other second
- Added the needed redis service in the GitHub Actions
- Added support for optional/missing sprint dates and missing boards
- All the sprints that are matched are removed
- XSRevert "Updated the needed Gem versions"
- Updated the needed Gem versions
- Catching exceptions to add more context in case of error
- Request rate limiting using redis and ratelimit gems
- GitHub Actions Board adjusted and jira instance boards filtered accordingly.
- Switching GitHub Action board to a Scrum Board
- Tweaked the logging
- Implemented --sprint-prefix-list and replaced CRLF with LF in files
- Fixed --sprint-list to only used sprint based boards
- Fixed RequestBuilder and subclassed to use the context_path
- --board-list the Jira instance board using a board_name_regex when defined
- Fixed broken xxx_when_defined_else
- Enabling the HttpClient patch so that context_path works as expected.
- Implemented --board-list and JIRA_PROJECT_KEY
- Added JIRA_CONTEXT_PATH
- Ruby load path to include scrip_path/../lib
- Bumped Aruba timeout to 300 seconds
- Added sprint filtering using an ART_SPRINT_REGEX environment variable
- Ignoring rerun_failures.txt used for Cucumber failure reruns
- The originBoardId is used to create sprints following an existing instead of a single board id.
- guard cucumber tor rerun failed features first if any
- Finalized team tickets dispatching on sprints according to expected start dates
- Ticket dispatching is now assigning a sprint to a ticket
- Added the matching of sprint to the corresponding prefix sprint
- Implemented creating tickets with custom fields and fetching the actual ticket values.
- Specifying the badge labels
- GitHub Actions - Updated to monitor all branches
- Cleaned TeamSprintPrefixMapper spec further
- Simplified TeamSprintPrefixMapper
- Ignoring /log directory
- Implemented mapping sprints to team names
- Implemented fetching field options
- JAT-15 - Implemented the ability to find the implementation_team and expected_start_date fields.
- Implemented jira_resource_double to centrally deal with rubocop:disable RSpec/VerifiedDoubles
- More robust sprint comparison using start_date, end_date and parsed_name
- Removed unused class
- Fixed broken --board-name=
- Fixed Rubocop warnings
- Updated the gem dependencies
- Finalized --sprint-add-until={current,coming}_quarter with current date time overridding
- Fixed 4-day sprint infinite loop issue where 24.4.10 was not > 24.4.9.
- Added logging statement and writing logs to a log directory.
- Incorrect UntilDate format should throw an error
- Implemented UntilDate and sprint loading pagination
- Create the next sprint using Sprint::Prefix#last_sprint
- Confirming that --sprint-add-one can handle multiple sprints
- Implemented --sprint-add-one when a single unclosed sprint exists
- Updating to Ruby 3.4.1
- Switching to Ruby 3.4 version in GitHub Actions
- Ruby 3.4. Using `#Thread::Backtrace::Location#base_label` to only get the method name
- Fixed typo in GitHub Actions file
- Configured the JIRA environment variables for GitHub Actions
- Renamed Jira::Sprint::Tool to Jira::Auto::Tool
- Renamed jira-sprint-tool command to jira-auto-tool
- Fixed an English typo.
- rubocop:disable RSpec/MultipleExpectations for Tool#create_sprint
- Added tests for SprintCreator
- Migrated tests for RequestBuilder and SprintStateUpdater
- Made RequestBuilder logging quieter
- Disabled Cucumber.io report publishing banner
- Removed unused code due to refactoring
- Moved RequestBuilder and subclasses in separate files
- Removed request handling duplication
- Refactoring request code
- Reducing the length of methods
- Fixed broken #create_sprint and #update_sprint_state tests
- Warning displayed when no unclosed sprint exist
- Dynamically creating closed sprints
- Removed duplication by using Jira::Sprint::Tool instead of the Jira client
- Handling the case where no sprint exist on the board
- Intermediate state to switch to Windows based development
- Create dependabot.yml
- Added guard for continuous local testing
- Adjusting GitAction badge URL
- Updated bundler dependencies
- Made the GitHub Action status visible on the README
- Removing 3.4.0 from the build matrix since that fails
- Added cucumber as part of the default rake target
- Turn of matrix fail-fast to know which versions are failing
- Added 3.4.0 in the build matrix
- Configure Rubocop and corrected warnings
- Switching to ruby 3.3.6
- Implemented basic --help
- Remove rspec initial failing test
- Initial commit after 'bundle gem ...'


