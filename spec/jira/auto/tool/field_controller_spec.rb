# frozen_string_literal: true

require "spec_helper"

require "jira/auto/tool/field_controller"

module Jira
  module Auto
    class Tool
      class FieldController
        RSpec.describe FieldController do
          let(:jira_client) { instance_double(JIRA::Client) }
          let(:controller) { described_class.new(jira_client) }

          def build_field(name = "a field name #{rand}", type = "unexpected_type")
            instance_double(Field, name: name, type: type)
          end

          RSpec.shared_examples "a field fetcher" do |method_under_test, expected_field_name, expected_field_type|
            let(:expected_field) { build_field(expected_field_name, expected_field_type) }
            let(:field_with_incorrect_type_name) { "non_#{expected_field_type}_field" }

            before do
              allow(controller)
                .to receive(:ticket_fields)
                .and_return([build_field, expected_field, build_field(field_with_incorrect_type_name), build_field])
            end

            context "when the field is found" do
              let(:actual_field) { controller.send(method_under_test, expected_field_name) }

              it "returns the expected field" do
                expect(actual_field).to eq(expected_field)
              end

              it "has the expected type" do
                expect(actual_field.type).to eq(expected_field_type)
              end
            end

            it "report an unexpected field type" do
              expect { controller.send(method_under_test, field_with_incorrect_type_name) }
                .to raise_error(
                  ExpectedFieldTypeError,
                  /Field\ '#{field_with_incorrect_type_name}'\ expected\ to\ have\ type\ '#{expected_field_type}',
                \ but\ was \ 'unexpected_type'./x
                )
            end

            it "raises and error for a non existing field" do
              expect { controller.send(method_under_test, "non_existing_field") }
                .to raise_error(FieldNotFoundError, /Field 'non_existing_field' not found!/)
            end
          end

          describe "#expected_start_date_field" do
            it_behaves_like "a field fetcher", :expected_start_date_field, "Custom Start Date", "date"
          end

          describe "#implementation_team_field" do
            it_behaves_like "a field fetcher", :implementation_team_field, "Custom Team", "option"
          end

          describe "#sprint_field" do
            it_behaves_like "a field fetcher", :sprint_field, "Custom Sprint", "array"
          end

          describe "#ticket_fields" do
            let(:board_id) { 123 }
            let(:jira_fields) do
              [
                %w[field1 date customfield_12345],
                %w[field2 option customfield_12346]
              ].collect { |attributes| build_jira_field(*attributes) }
            end
            let(:expected_fields) { jira_fields.collect { |f| Field.new(jira_client, f) } }

            def build_jira_field(name, type, id)
              jira_resource_double(JIRA::Resource::Field, name:, schema: { "type" => type }, id:)
            end

            before do
              # rubocop:disable  RSpec/MessageChain
              allow(jira_client).to receive_message_chain(:Field, :all).and_return(jira_fields)
              # rubocop:enable  RSpec/MessageChain
            end

            context "when fields are successfully fetched" do
              it "returns fields associated with the board" do
                expect(controller.ticket_fields).to eq(expected_fields)
              end
            end

            context "when an error occurs" do
              before do
                # rubocop:disable  RSpec/MessageChain
                allow(jira_client).to receive_message_chain(:Field, :all).and_raise(StandardError,
                                                                                    "Something went wrong")
                # rubocop:enable  RSpec/MessageChain
              end

              it "raises an error with a descriptive message" do
                expect do
                  controller.ticket_fields
                end.to raise_error(RuntimeError, /Error fetching project ticket fields: Something went wrong/)
              end
            end
          end
        end
      end
    end
  end
end
