# frozen_string_literal: true

require "spec_helper"

require "jira/auto/tool/project"

module Jira
  module Auto
    class Tool
      class Project
        RSpec.describe Project do
          let(:tool) { instance_double(Tool, jira_client: jira_client) }
          let(:jira_client) { instance_double(JIRA::Client) }

          describe ".find" do
            let(:jira_project) { jira_resource_double(JIRA::Resource::Project, key: "project_key") }
            let(:actual_end_date) { described_class.find(tool, "project_key") }

            before do
              allow(jira_client)
                .to receive_messages(Project: jira_resource_double("project_query", find: jira_project))
            end

            it { expect(actual_end_date.key).to eq("project_key") }
            it { expect(actual_end_date).to be_a(described_class) }
          end
        end
      end
    end
  end
end
