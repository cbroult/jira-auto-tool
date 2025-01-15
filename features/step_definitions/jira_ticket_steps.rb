# frozen_string_literal: true

And(/^tickets on the board have an expected date field named "([^"]*)"$/) do |date_field_name|
  @date_field = @jira_auto_tool.expected_start_date_field(date_field_name)

  expect(@date_field).not_to be_nil
end

And(/^tickets on the board have a team field named "([^"]*)" with exactly those values:$/) do
|team_field_name, field_values|

  expected_field_values = field_values.hashes.collect { |hashes| hashes["values"] }

  @team_field = @jira_auto_tool.implementation_team_field(team_field_name)

  expect(@team_field.values.collect(&:value)).to eq(expected_field_values)
end

Given(/^the following tickets exist:$/) do |ticket_table|
  # Summary | Description | Implementation Team | Expected Start |
  # table is a table.hashes.keys # => [:summary, :team, :expected_start]
  ticket_table.hashes.each do |ticket_info|
    log.debug { ticket_info.inspect }

    jira_ticket = @jira_auto_tool.jira_client.Issue.build

    jira_ticket.save!({ fields: {
                        project: { key: @jira_auto_tool.board.project_key },
                        summary: ticket_info[:summary],
                        description: ticket_info[:description],
                        issuetype: { name: "Task" },
                        @jira_auto_tool.implementation_team_field.id.intern =>
                     { "value" => ticket_info[:implementation_team] },
                        @jira_auto_tool.expected_start_date_field.id.intern => ticket_info[:expected_start_date]
                      } })

    log.debug { "created jira ticket: #{jira_ticket.key}" }
  end
end

Then(/^the tickets should have been assigned to sprints as follows:$/) do |ticket_expectation_table|
  # table is a table.hashes.keys # => [:summary, :sprint]
  ticket_expectations =
    ticket_expectation_table.hashes.collect { |expectation| [expectation[:summary], expectation[:sprint]] }

  actual_ticket_values = @jira_auto_tool.tickets.collect do |ticket|
    sprint = ticket.sprint

    log.debug { "ticket: #{ticket.summary} sprint: #{sprint.inspect}" }

    [ticket.summary, sprint ? sprint.first["name"] : ""]
  end

  expect(actual_ticket_values.sort).to eq(ticket_expectations.sort)
end

And(/^the following environment variables are set:$/) do |table|
  table.hashes.each do |env_var|
    name = env_var.fetch("name")
    value = env_var.fetch("value")
    @jira_auto_tool.send("#{name.downcase}=", value)
    set_environment_variable(name, value)
  end
end
