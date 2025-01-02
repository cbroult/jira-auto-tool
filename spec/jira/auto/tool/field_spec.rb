# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/field"

RSpec.describe Jira::Auto::Tool::Field do
  let(:field) { described_class.new(jira_client, jira_field) }

  let(:jira_client) { jira_resource_double(JIRA::Client) }

  let(:jira_field) do
    jira_resource_double(
      JIRA::Resource::Field,
      name: "Field Name",
      schema: { "type" => "string" },
      id: "customfield_12345"
    )
  end

  describe "#initialize" do
    it "assigns jira_client" do
      expect(field.jira_client).to eq(jira_client)
    end

    it "assigns jira_field" do
      expect(field.jira_field).to eq(jira_field)
    end
  end

  describe "#name" do
    it "returns the field name" do
      expect(field.name).to eq("Field Name")
    end
  end

  describe "#type" do
    it "returns the field type" do
      expect(field.type).to eq("string")
    end
  end

  describe "#id" do
    it "returns the field id" do
      expect(field.id).to eq("customfield_12345")
    end
  end
end
