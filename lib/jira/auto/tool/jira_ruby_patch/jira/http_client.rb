# frozen_string_literal: true

require "jira-ruby"
require "jira/http_client"

module JIRA
  PATCH_ENABLED = true

  if PATCH_ENABLED
    class HttpClient
      def make_cookie_auth_request
        body = { username: @options[:username].to_s, password: @options[:password].to_s }.to_json
        @options.delete(:username)
        @options.delete(:password)
        make_request(:post, "/rest/auth/1/session", body, "Content-Type" => "application/json")
      end

      def request_path(url)
        parsed_uri = URI(url)

        path = parsed_uri.is_a?(URI::HTTP) ? parsed_uri.request_uri : url

        @options[:context_path] + path
      end
    end
  end
end
