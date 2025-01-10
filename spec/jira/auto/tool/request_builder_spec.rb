# frozen_string_literal: true

require "rspec"

RSpec.describe Jira::Auto::Tool::RequestBuilder do
  describe "#run" do
    let(:request_builder) { described_class.new(jira_client) }

    let(:jira_client) do
      jira_client = instance_spy(JIRA::Client).as_null_object
      allow(JIRA::Client).to receive_messages(new: jira_client)
      jira_client
    end

    let(:expected_response) do
      instance_double(Net::HTTPResponse, code: 200, body: "sprint updated successfully")
    end

    describe "#context_path" do
      before do
        allow(jira_client).to receive_messages(options: { context_path: "/path/to/context" })
      end

      it { expect(request_builder.send(:context_path)).to eq("/path/to/context") }
    end

    describe "#request_path_with_context" do
      before do
        allow(request_builder).to receive_messages(context_path: "/path/to/context", request_path: "/request/path")
      end

      it { expect(request_builder.send(:request_path_with_context)).to eq("/path/to/context/request/path") }
    end

    describe "#run" do
      before do
        allow(jira_client).to receive_messages(put: expected_response)

        allow(request_builder).to receive_messages(
          http_verb: :put,
          context_path: "/path/to/context", request_path: "/request/path",
          request_payload: { some_payload: "value" },
          expected_response: 200,
          error_message_prefix: "Error updating auto state",
          success_message_prefix: "Sprint state updated successfully"
        )
      end

      it "sends the expected request" do
        request_builder.run

        expect(jira_client).to have_received(:put)
          .with("/path/to/context/request/path",
                { some_payload: "value" }.to_json,
                { "Content-Type" => "application/json" })
      end

      it "returns the response" do
        allow(request_builder).to receive_messages(send_request: expected_response, expected_response: 200)

        expect(request_builder.run).to eq(expected_response)
      end
    end

    describe ".build_request_args" do
      it "removes payload as an argument if it is nil" do
        allow(request_builder).to receive_messages(request_headers: :some_headers)

        expect(request_builder.send(:build_request_args, "/request/path", nil)).to eq(["/request/path", :some_headers])
      end
    end
  end
end
