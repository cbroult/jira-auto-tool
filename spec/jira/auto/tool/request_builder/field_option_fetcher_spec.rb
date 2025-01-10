# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/request_builder/field_option_fetcher"

module Jira
  module Auto
    class Tool
      class RequestBuilder
        RSpec.describe FieldOptionFetcher do
          let(:field_option_fetcher) { described_class.new(jira_client, field, field_context) }
          let(:jira_client) { instance_spy(JIRA::Client, options: { context_path: :a_context_path }).as_null_object }
          let(:field_context) { { "id" => context_id, "name" => "a context name" }.symbolize_keys }

          let(:field) do
            instance_double(Field, jira_client: jira_client, name: "a field name", type: "option",
                                   id: "customfield_10000")
          end

          let(:context_id) { "10567" }

          before do
            allow(FieldContextFetcher)
              .to receive_messages(fetch_field_contexts: [field_context])
          end

          it do
            expect(field_option_fetcher.send(:request_path))
              .to eq("/rest/api/3/field/#{field.id}/context/#{context_id}/option")
          end

          # rubocop:disable RSpec/MultipleMemoizedHelpers
          describe ".fetch_field_options" do
            let(:id_value_pairs) do
              [
                ["option_id_128", "a field option value"],
                ["option_id_256", "another field option value"],
                ["option_id_512", "yet another field option value"]
              ]
            end

            let(:jira_options) { id_value_pairs.collect { |id, value| { "id" => id, "value" => value } } }

            let(:actual_response) do
              instance_double(Net::HTTPResponse, code: "200", body: { "values" => jira_options }.to_json)
            end

            let(:actual_field_options) do
              id_value_pairs.collect { |id, value| FieldOption.new(jira_client, id, value) }
            end

            it "returns the actual field options" do
              allow(jira_client).to receive_messages(send: actual_response)
              allow(field).to receive_messages(field_context: field_context)

              expect(described_class.fetch_field_options(field)).to eq(actual_field_options)
            end
          end
          # rubocop:enable RSpec/MultipleMemoizedHelpers
        end
      end
    end
  end
end
