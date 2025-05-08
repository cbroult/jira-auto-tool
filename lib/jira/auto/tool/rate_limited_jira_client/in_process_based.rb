# frozen_string_literal: true

require "ruby-limiter"

require_relative "../rate_limited_jira_client"

module Jira
  module Auto
    class Tool
      class RateLimitedJiraClient
        class InProcessBased < RateLimitedJiraClient
          def rate_limit(&block)
            rate_queue.shift

            block.call
          end

          def rate_queue
            @rate_queue ||=
              Limiter::RateQueue.new(rate_limit_per_interval, interval: rate_interval_in_seconds)
          end
        end
      end
    end
  end
end
