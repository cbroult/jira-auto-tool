# frozen_string_literal: true

#
# require "jira-ruby"
# require "json"
#
# # Jira client setup
# options = {
#   username: "your_username", # Replace with Jira username
#   password: "your_api_token", # Replace with your API token for authentication
#   site: "https://your-domain.atlassian.net", # Replace with your Jira instance URL
#   context_path: "",
#   auth_type: :basic
# }
#
# client = JIRA::Client.new(options)
#
# # Get issue metadata for project and custom field
# def fetch_custom_field_options(client, project_key, custom_field_id)
#   # Fetch issue metadata for the project
#   response = client.get("/rest/api/3/issue/createmeta?projectKeys=#{project_key}&expand=projects.issuetypes.fields")
#   metadata = JSON.parse(response.body)
#
#   # Parse metadata for the specified custom field
#   options = []
#   metadata["projects"].each do |project|
#     project["issuetypes"].each do |issuetype|
#       fields = issuetype["fields"] || {}
#       if fields[custom_field_id] && fields[custom_field_id]["allowedValues"]
#         options = fields[custom_field_id]["allowedValues"].map { |option| option["value"] }
#       end
#     end
#   end
#
#   # Return unique options
#   options.uniq
# rescue JIRA::HTTPError => e
#   puts "Failed to fetch field metadata: #{e.response.body}"
#   nil
# end
#
# # Replace with your Jira project key and the custom field ID
# project_key = "PROJ"
# custom_field_id = "customfield_10021" # Replace with your custom field ID
# options = fetch_custom_field_options(client, project_key, custom_field_id)
#
# puts "Possible values: #{options}"
