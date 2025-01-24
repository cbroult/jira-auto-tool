# frozen_string_literal: true

require "jira/auto/tool/rate_limited_jira_client"

module Jira
  module Auto
    class Tool
      class RateLimitedJiraClient
        RSpec.describe RateLimitedJiraClient do
          describe "#request" do
            let(:client) { described_class.new({}, rate_interval:, rate_limit:) }
            let(:rate_interval) { 2 }
            let(:rate_limit) { 1 }
            let(:oauth_client) { instance_double(JIRA::OauthClient, request: nil, consumer: nil) }
            let(:rate_limiter) { instance_double(Ratelimit) }

            before do
              allow(described_class).to receive_messages(rate_limiter: rate_limiter)

              allow(JIRA::OauthClient).to receive_messages(new: oauth_client)

              allow(client).to receive_messages(original_request: :response)

              allow(rate_limiter).to receive_messages(add: nil)
              allow(rate_limiter).to receive(:exec_within_threshold).and_yield
            end

            it "returns the response" do
              expect(client.request(:get, "/path/to/resource")).to eq(:response)
            end

            it "calls the original request method" do
              client.request(:get, "/path/to/resource")

              expect(client).to have_received(:original_request).with(:get, "/path/to/resource")
            end

            context "when it leverages the rate limiter" do
              it "uses :exec_within_threshold to control rate limiting" do
                allow(rate_limiter).to receive_messages(exec_within_threshold: nil)

                4.times { client.request(:get, "/path/to/resource") }

                expect(rate_limiter)
                  .to have_received(:exec_within_threshold)
                  .with("jira_auto_tool_api_requests", { interval: rate_interval, threshold: rate_limit })
                  .exactly(4).times
              end

              it "adds keeps track of the rate limiter key calls" do
                allow(rate_limiter).to receive_messages(add: nil)

                4.times { client.request(:get, "/path/to/resource") }

                expect(rate_limiter)
                  .to have_received(:add)
                  .with("jira_auto_tool_api_requests")
                  .exactly(4).times
              end
            end

            context "when it does not leverage the rate limiter" do
              let(:rate_limit) { 0 }

              it "does not use :exec_within_threshold to control rate limiting" do
                client.request(:get, "/path/to/resource")

                expect(rate_limiter).not_to have_received(:exec_within_threshold)
              end

              it "calls the original request method" do
                client.request(:get, "/path/to/resource")

                expect(client).to have_received(:original_request).with(:get, "/path/to/resource")
              end
            end
          end
        end
      end
    end
  end
end
