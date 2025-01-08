# frozen_string_literal: true

require "rspec"

require "jira/auto/tool/jira_ruby_patch/jira/http_client"

module JIRA
  class HttpClient
    RSpec.describe JIRA::HttpClient do
      let(:options) do
        {
          rest_base_path: "rest_base_path",
          site: "jira_site_url_value",
          context_path: context_path,
          username: "jira_username_value",
          password: "jira_api_token_value",
          auth_type: :basic
        }
      end

      let(:http_client) { described_class.new(options) }

      describe "#request_path" do
        context "when no context path is set" do
          let(:context_path) { "" }

          it { expect(http_client.send(:request_path, "/some/path")).to eq("/some/path") }
        end

        if JIRA::PATCH_ENABLED
          context "when using a context_path" do
            let(:context_path) { "/path/to/context" }

            it { expect(http_client.send(:request_path, "/some/path")).to eq("/path/to/context/some/path") }
          end
        end
      end
    end
  end
end
