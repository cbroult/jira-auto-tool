# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class RequestBuilder
        class ProjectTicketCreationMetadataFetcher
          DISABLED = true

          # TODO: write tests and implement
          unless DISABLED
            require "jira-ruby"

            # Jira client configuration
            options = {
              username: "your_username", # Replace with your Jira username
              password: "your_api_token", # Replace with your Jira API token
              site: "https://your-jira-instance.atlassian.net", # Replace with your Jira URL
              context_path: "",
              auth_type: :basic
            }

            client = JIRA::Client.new(options)

            # Fetch metadata about issue creation
            project_key = "PROJECT_KEY" # Replace with your project key
            begin
              response = client
                         .get("/rest/api/2/issue/createmeta" \
                              "?projectKeys=#{project_key}" \
                              "&expand=projects.issuetypes.fields")

              createmeta = JSON.parse(response.body)

              # Output the metadata
              puts "Metadata for project #{project_key}:"
              createmeta["projects"].each do |project|
                puts "Project Name: #{project["name"]}"
                project["issuetypes"].each do |issuetype|
                  puts "- Issue Type: #{issuetype["name"]}"
                  issuetype["fields"].each do |field_id, field_info|
                    puts "  * Field: #{field_info["name"]} (ID: #{field_id}, Required: #{field_info["required"]})"
                  end
                end
              end
            rescue StandardError => e
              puts "Error fetching metadata: #{e.message}"
            end
          end
        end
      end
    end
  end
end
