# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class RateLimitedJiraClient < JIRA::Client
        require_relative "rate_limited_jira_client/in_process_based"
        require_relative "rate_limited_jira_client/redis_based"

        def self.implementation_class_for(tool)
          requested_implementation = tool.jat_rate_limit_implementation_when_defined_else nil

          case requested_implementation
          when "in_process", "", nil
            InProcessBased
          when "redis"
            RedisBased
          else
            raise %(#{requested_implementation.inspect}: unexpected rate limiting implementation specified!")
          end
        end

        NO_RATE_LIMIT_PER_INTERVAL = 0
        NO_RATE_INTERVAL_IN_SECONDS = 0

        attr_reader :rate_interval_in_seconds, :rate_limit_per_interval

        def initialize(options, rate_interval_in_seconds: 1, rate_limit_per_interval: 1)
          super(options)
          @rate_interval_in_seconds = rate_interval_in_seconds
          @rate_limit_per_interval = rate_limit_per_interval
        end

        alias original_request request

        def request(*args)
          if rate_limit_per_interval == NO_RATE_LIMIT_PER_INTERVAL
            original_request(*args)
          else
            rate_limit { original_request(*args) }
          end
        end

        def rate_limit(&)
          raise "rate_limit must be implemented by a subclass"
        end
      end
    end
  end
end
