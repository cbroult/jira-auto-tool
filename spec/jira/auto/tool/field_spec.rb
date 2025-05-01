# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/field"

module Jira
  module Auto
    class Tool
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

        # TODO
        describe "#values" do
          let(:field_options) { [instance_double(FieldOption)] }

          it "fetches the field values" do
            allow(RequestBuilder::FieldOptionFetcher)
              .to receive(:fetch_field_options).with(field).and_return(field_options)

            expect(field.values).not_to be_empty
          end
        end

        describe "#field_context" do
          let(:logger) { instance_double(Logger) }

          before do
            allow(field)
              .to receive_messages(field_contexts: %i[first_context second_context third_context],
                                   log: logger)
          end

          it "returns the first context associated to a field and warns about multiple contexts" do
            expect(logger).to receive(:warn)

            expect(field.field_context).to eq(:first_context)
          end
        end

        describe "#field_contexts" do
          before do
            allow(RequestBuilder::FieldContextFetcher)
              .to receive_messages(fetch_field_contexts: %i[first_context second_context third_context])
          end

          it { expect(field.field_contexts).to eq(%i[first_context second_context third_context]) }
        end

        # TODO: - implement and maybe create a shared example to simplfy and reuse
        describe "#<=>" do
          def build_field(name, type, id)
            # descr
          end

          it { expect(true).to be_truthy }
        end
      end
    end
  end
end
