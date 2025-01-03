# frozen_string_literal: true

require "jira/auto/tool/request_builder/get"

module Jira
  module Auto
    class Tool
      class RequestBuilder
        RSpec.describe Get do
          let(:jira_client) { instance_double(JIRA::Client) }
          let(:request_builder) { described_class.new(jira_client) }

          describe "#request_payload" do
            it "returns nil" do
              expect(request_builder.request_payload).to be_nil
            end
          end

          describe "#http_verb" do
            it "returns :get" do
              expect(request_builder.http_verb).to eq(:get)
            end
          end

          describe "#expected_response" do
            it "returns 200" do
              expect(request_builder.expected_response).to eq(200)
            end
          end

          describe "#request_headers" do
            it "returns nil" do
              expect(request_builder.request_headers).to be_nil
            end
          end
        end
      end
    end
  end
end
