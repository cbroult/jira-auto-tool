# frozen_string_literal: true

require "rspec"

require "jira/auto/tool/jira_ruby_patch/jira/http_client"

module JIRA
  class Client
    ENABLED = false
    if ENABLED
      RSpec.describe JIRA::Cliebt do
        let(:options) do
          {
            site: "jira_site_url_value",
            rest_base_path: "/rest/base/path",
            context_path: context_path,
            username: "jira_username_value",
            password: "jira_api_token_value",
            auth_type: :basic
          }
        end

        let(:client) { described_class.new(options) }

        describe "@rest_base_path" do
          context "when no context path is set" do
            let(:context_path) { "" }

            it {
              expect(client.instance_eval("@options[:rest_base_path]", __FILE__, __LINE__)).to eq("/rest/base/path")
            }

            describe "#get" do
              let(:http_client) { instance_double(JIRA::HttpClient, request: nil) }

              before do
                allow(JIRA::HttpClient).to receive_messages(new: http_client)
              end

              it "does not prefix the path with any context path" do
                client.get("/path/to/resource")

                expect(http_client).to have_received(:request).with(:get, "/path/to/resource", nil)
              end
            end
          end

          context "when using a context_path" do
            let(:context_path) { "/path/to/context" }

            it {
              expect(client.instance_eval("@options[:rest_base_path]", __FILE__,
                                          __LINE__ - 1)).to eq("/path/to/context/rest/base/path")
            }

            describe "#get" do
              let(:http_client) { instance_double(JIRA::HttpClient, request: nil) }

              before do
                allow(JIRA::HttpClient).to receive_messages(new: http_client)
              end

              it "does not prefix the path with any context path" do
                client.get("/path/to/resource")

                expect(http_client).to have_received(:request).with(:get, "/path/to/context/path/to/resource", nil)
              end
            end
          end
        end
      end
    end
  end
end
