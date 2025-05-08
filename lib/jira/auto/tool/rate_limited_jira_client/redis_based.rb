# frozen_string_literal: true

require_relative "../rate_limited_jira_client"
require "ratelimit"
require "redis"

require "jira/auto/tool"

module Jira
  module Auto
    class Tool
      class RateLimitedJiraClient
        class RedisBased < RateLimitedJiraClient
          def rate_limit(&block)
            rate_limiter.exec_within_threshold(rate_limiter_key, interval: rate_interval_in_seconds,
                                                                 threshold: rate_limit_per_interval) do
              response = block.call

              rate_limiter.add(rate_limiter_key)

              response
            end
          end

          def rate_limiter_key
            "jira_auto_tool_api_requests"
          end

          def rate_limiter
            self.class.rate_limiter(rate_limiter_key, rate_interval_in_seconds)
          end

          def self.rate_limiter(rate_limiter_key, rate_interval)
            @rate_limiter ||= Ratelimit.new(rate_limiter_key, bucket_interval: rate_interval)
          end
        end
      end
    end
  end
end
