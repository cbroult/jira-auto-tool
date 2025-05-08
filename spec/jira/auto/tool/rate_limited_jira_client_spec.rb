# frozen_string_literal: true

require "rspec"

module Jira
  module Auto
    class Tool
      RSpec.describe RateLimitedJiraClient do
        describe ".implementation_class_for" do
          let(:result) { described_class.implementation_class_for(tool) }
          let(:tool) { instance_double(Tool) }

          context "when the rate limiting implementation is unspecified" do
            before do
              allow(tool).to receive_messages(jat_rate_limit_implementation_when_defined_else: nil)
            end

            it { expect(result).to eq(RateLimitedJiraClient::InProcessBased) }
          end

          context "when using in process based rate limiting" do
            before do
              allow(tool).to receive_messages(jat_rate_limit_implementation_when_defined_else: "in_process")
            end

            it { expect(result).to eq(RateLimitedJiraClient::InProcessBased) }
          end

          context "when using in Redis based rate limiting" do
            before do
              allow(tool).to receive_messages(jat_rate_limit_implementation_when_defined_else: "redis")
            end

            it { expect(result).to eq(RateLimitedJiraClient::RedisBased) }
          end

          context "when the request implementation is unexpected" do
            before do
              allow(tool)
                .to receive_messages(jat_rate_limit_implementation_when_defined_else: "unexpected_implementation")
            end

            it do
              expect { result }
                .to raise_error(RuntimeError,
                                %("unexpected_implementation": unexpected rate limiting implementation specified!"))
            end
          end
        end

        RSpec.shared_examples "a rate limited client" do
          before do
            allow(client).to receive_messages(original_request: :response)
          end

          it "returns the response" do
            expect(client.request(:get, "/path/to/resource")).to eq(:response)
          end

          it "calls the original request method" do
            client.request(:get, "/path/to/resource")

            expect(client).to have_received(:original_request).with(:get, "/path/to/resource")
          end
        end

        describe "#request" do
          let(:client) { described_class.new({}, rate_interval_in_seconds:, rate_limit_per_interval:) }

          context "when the rate limiter is not needed" do
            let(:rate_interval_in_seconds) { 0 }
            let(:rate_limit_per_interval) { 0 }

            it_behaves_like "a rate limited client"

            it "does not use the rate limiter" do
              allow(client).to receive(:original_request).with(:get, "/path/to/resource")
              expect(client).not_to receive(:rate_limit)

              client.request(:get, "/path/to/resource")
            end
          end

          context "when the rate limiter is needed" do
            let(:rate_interval_in_seconds) { 2 }
            let(:rate_limit_per_interval) { 1 }

            it_behaves_like "a rate limited client" do
              before { allow(client).to receive(:rate_limit).and_yield }
            end

            it "uses the rate limiter" do
              allow(client).to receive(:original_request).with(:get, "/path/to/resource")
              expect(client).to receive(:rate_limit).and_yield

              client.request(:get, "/path/to/resource")
            end
          end
        end
      end
    end
  end
end
