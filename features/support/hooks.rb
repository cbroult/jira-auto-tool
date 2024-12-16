# frozen_string_literal: true

require "jira-ruby"

jira_options = {
  site: "https://cbroult.atlassian.net/",
  context_path: "",
  auth_type: :basic,
  username: "cbroult@yahoo.com",
  password: ENV.fetch("JIRA_API_TOKEN").chomp
}

Before do
  @jira_client = JIRA::Client.new(jira_options)
  board_mame = "JST - Self-Test Board - Dev"
  @board = @jira_client.Board.all.find { |board| board.name == board_mame } || raise("#{board_mame}: Board not found")

  remove_existing_sprints(@board)
end
