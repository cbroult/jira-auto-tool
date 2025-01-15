# frozen_string_literal: true

require "ratelimit"
require "redis"

require "jira/auto/tool"

module Jira
  module Auto
    class Tool
      class RateLimitedJiraClient < JIRA::Client
        attr_reader :rate_interval, :rate_limit

        def initialize(options, rate_interval: 4, rate_limit: 1)
          super(options)
          @rate_interval = rate_interval
          @rate_limit = rate_limit
        end

        alias original_request request
        def request(*args)
          rate_limiter.exec_within_threshold(rate_limiter_key, interval: rate_interval, limit: rate_limit) do
            original_request(*args)
          end
        end

        def rate_limiter_key
          "jira_auto_tool_api_requests"
        end

        def rate_limiter
          self.class.rate_limiter(rate_limiter_key, rate_interval)
        end

        def self.rate_limiter(rate_limiter_key, rate_interval)
          @rate_limiter ||= Ratelimit.new(rate_limiter_key, bucket_interval: rate_interval)
        end
      end
    end
  end
end
