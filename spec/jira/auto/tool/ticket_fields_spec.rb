# frozen_string_literal: true

# //wsl.localhost/Ubuntu/home/cbroult/work/ruby/jira-auto-tool/features/ticket_fields_spec.rb

require "spec_helper"
require "jira/auto/tool/ticket"

module Jira
  module Auto
    class Tool
      RSpec.describe Jira::Auto::Tool::Ticket do
        let(:tool) { instance_double(Tool) }

        describe "#ticket_fields" do
          context "when JIRA API V2, jira_ticket responds to #fields" do
            let(:jira_ticket_with_fields) do
              jira_resource_double(JIRA::Resource::Issue, fields: { "example_field" => "value" })
            end

            it "returns the fields hash" do
              ticket = described_class.new(tool, jira_ticket_with_fields)
              expect(ticket.ticket_fields).to eq({ "example_field" => "value" })
            end
          end

          context "when JIRA API V3, jira_ticket does not respond to #fields but responds to #attrs" do
            let(:jira_ticket_with_attrs) do
              jira_resource_double(JIRA::Resource::Issue, attrs: { "fields" => { "example_field" => "value" } })
            end

            let(:jira_ticket_with_invalid_attrs) do
              jira_resource_double(JIRA::Resource::Issue, attrs: { "invalid" => "data" })
            end

            it "returns the fields hash from attrs" do
              ticket = described_class.new(tool, jira_ticket_with_attrs)
              expect(ticket.ticket_fields).to eq({ "example_field" => "value" })
            end

            it "raises an error if fields are not found in attrs" do
              ticket = described_class.new(tool, jira_ticket_with_invalid_attrs)
              expect do
                ticket.ticket_fields
              end
                .to raise_error("fields not found in {\"invalid\" => \"data\"} from #{jira_ticket_with_invalid_attrs}!")
            end
          end

          context "when jira_ticket does not respond to #fields or #attrs" do
            let(:jira_ticket_without_fields_or_attrs) { jira_resource_double(JIRA::Resource::Issue) }

            it "raises an error indicating attrs are not found" do
              ticket = described_class.new(tool, jira_ticket_without_fields_or_attrs)
              expect do
                ticket.ticket_fields
              end.to raise_error("attrs not found in #{jira_ticket_without_fields_or_attrs}!")
            end
          end
        end
      end
    end
  end
end
