# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/request_builder/field_context_fetcher"

module Jira
  module Auto
    class Tool
      class RequestBuilder
        RSpec.describe FieldContextFetcher do
          let(:field_context_fetcher) { described_class.new(jira_client, field) }

          let(:field) do
            instance_double(Field, jira_client: jira_client, name: "a field name", type: "option",
                                   id: "customfield_10000")
          end

          let(:jira_client) { instance_spy(JIRA::Client).as_null_object }

          it do
            expect(field_context_fetcher.send(:request_url))
              .to eq("/rest/api/3/field/#{field.id}/context")
          end

          # rubocop:disable RSpec/MultipleMemoizedHelpers
          describe ".fetch_field_contexts" do
            let(:id_name_pairs) do
              [
                [10_578, "a field context name"],
                [10_792, "another field context name"],
                [10_793, "yet another field context name"]
              ]
            end

            let(:jira_field_contexts) { id_name_pairs.collect { |id, name| { "id" => id, "name" => name } } }

            let(:actual_response) do
              instance_double(Net::HTTPResponse, code: "200", body: { "values" => jira_field_contexts }.to_json)
            end

            let(:actual_field_contexts) { jira_field_contexts.collect(&:symbolize_keys) }

            it "returns the actual field options" do
              allow(jira_client).to receive_messages(send: actual_response)

              expect(described_class.fetch_field_contexts(field)).to eq(actual_field_contexts)
            end
          end
          # rubocop:enable RSpec/MultipleMemoizedHelpers
        end
      end
    end
  end
end
