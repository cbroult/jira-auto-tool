# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/request_builder/sprint_state_updater"

module Jira
  module Auto
    class Tool
      class RequestBuilder
        DISABLED = true
        unless DISABLED
          RSpec.describe FieldOptionFetcher do
            let(:field_option_fetcher) { described_class.new(jira_client, field) }

            let(:field) { instance_double(Field, name: "a field name", type: "option", id: "customfield_10000") }

            let(:jira_client) { instance_spy(JIRA::Client).as_null_object }

            it { expect(field_option_fetcher.send(:request_url)).to eq("/rest/api/3/field/#{field.id}/option") }

            it { expect(field_option_fetcher.send(:http_verb)).to eq(:get) }

            it { expect(field_option_fetcher.send(:expected_response)).to eq(200) }

            it do
              expect(field_option_fetcher.send(:request_payload)).to eq({})
            end

            describe ".fetch_field_options" do
              let(:actual_response) do
                instance_double(Net::HTTPResponse, code: "201", body: { "id" => 512 }.to_json)
              end

              let(:actual_field_options) do
                [
                  instance_double(FieldOption),
                  instance_spy(JIRA::Resource::Sprint, id: 256),
                  instance_spy(JIRA::Resource::Sprint, id: 512)
                ]
              end

              it "returns the actual field options" do
                allow(jira_client).to receive_messages(send: actual_response)
                allow(jira_client).to receive_messages(Sprint: actual_sprints)
                allow(actual_sprints).to receive(:find).with(512).and_return(actual_sprints.last)

                expect(described_class.create_sprint(jira_client, 32, "a_name",
                                                     "2024-12-19 13:16 UTC",
                                                     14))
                  .to be_a(Sprint)
              end
            end
          end
        end
      end
    end
  end
end
