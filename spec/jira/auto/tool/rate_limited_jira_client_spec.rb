# frozen_string_literal: true

require "jira/auto/tool/rate_limited_jira_client"

module Jira
  module Auto
    class Tool
      class RateLimitedJiraClient
        RSpec.describe RateLimitedJiraClient do
          describe "#request" do
            let(:client) { described_class.new(options, rate_interval:, rate_limit:) }
            let(:rate_interval) { 1 }
            let(:rate_limit) { 1 }
            let(:options) { {} }
            let(:oauth_client) { instance_double(JIRA::OauthClient, request: nil, consumer: nil) }

            before do
              allow(JIRA::OauthClient).to receive_messages(new: oauth_client)
              allow(client).to receive_messages(original_request: nil)
            end

            it "calls the original request method" do
              4.times { client.request(:get, "/path/to/resource") }

              expect(client).to have_received(:original_request).exactly(4).times
            end
          end
        end
      end
    end
  end
end
