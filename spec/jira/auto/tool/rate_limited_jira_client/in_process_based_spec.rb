# frozen_string_literal: true

require "jira/auto/tool/rate_limited_jira_client/in_process_based"

module Jira
  module Auto
    class Tool
      class RateLimitedJiraClient
        class InProcessBased
          RSpec.describe InProcessBased do
            def build_client
              described_class.new({}, rate_interval_in_seconds:, rate_limit_per_interval:)
            end

            let(:client) { build_client }

            let(:rate_interval_in_seconds) { 2 }
            let(:rate_limit_per_interval) { 1 }

            describe "#rate_limit" do
              let(:rate_queue) { instance_double(Limiter::RateQueue) }

              it "properly initializes the rate queue" do
                allow(Limiter::RateQueue)
                  .to receive(:new).with(rate_limit_per_interval, interval: rate_interval_in_seconds)
                  .and_return(rate_queue)

                allow(rate_queue).to receive(:shift)

                expect(client.rate_limit { :do_nothing }).to eq(:do_nothing)
              end

              context "when rate limiting multiple requests" do
                let(:rate_limit_4_calls_to_original_request_code) do
                  4.times { client.rate_limit { client.original_request(:get, "/path/to/resource") } }
                end

                before do
                  allow(client).to receive(:original_request).with(:get, "/path/to/resource")
                  allow(client).to receive_messages(rate_queue: rate_queue)
                  allow(rate_queue).to receive(:shift)
                end

                it "shifts the queue and performs the request call" do
                  rate_limit_4_calls_to_original_request_code

                  expect(rate_queue).to have_received(:shift).exactly(4).times
                  expect(client).to have_received(:original_request).exactly(4).times
                end
              end

              describe "#rate_queue" do
                let(:another_client) { build_client }

                it "creating a second client will return another queue" do
                  expect(another_client.rate_queue).not_to equal(client.rate_queue)
                end
              end
            end
          end
        end
      end
    end
  end
end
