# frozen_string_literal: true

#
# def get_createmeta_for_project(client, project_key)
#   response = client.get("/rest/api/3/issue/createmeta?projectKeys=#{project_key}")
#   metadata = JSON.parse(response.body)
#
#   # Parse issue types and fields for the project
#   metadata["projects"].each do |project|
#     project["issuetypes"].each do |issuetype|
#       puts "Issue Type: #{issuetype["name"]}"
#
#       issuetype["fields"].each do |field_id, field_details|
#         puts "Field: #{field_details["name"]}, ID: #{field_id}"
#       end
#     end
#   end
# rescue JIRA::HTTPError => e
#   puts "Failed to retrieve create metadata: #{e.response.body}"
# end
#
# # Replace with your project key
# project_key = "PROJ"
# get_createmeta_for_project(client, project_key)
