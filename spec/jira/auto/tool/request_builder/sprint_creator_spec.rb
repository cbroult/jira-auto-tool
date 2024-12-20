# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/request_builder/sprint_state_updater"

RSpec.describe Jira::Auto::Tool::RequestBuilder::SprintCreator do
  let(:sprint_creator) do
    described_class.new(jira_client, board, "a_name", "2024-12-19 13:16 UTC", 14)
  end

  let(:jira_client) { instance_spy(JIRA::Client).as_null_object }

  let(:board) { instance_double(JIRA::Resource::Board, id: 32) }

  it { expect(sprint_creator.send(:request_url)).to eq("/rest/agile/1.0/sprint") }

  it { expect(sprint_creator.send(:http_verb)).to eq(:post) }

  it do
    expect(sprint_creator.send(:request_payload))
      .to eq({
               name: "a_name",
               startDate: "2024-12-19T13:16:00Z",
               endDate: "2025-01-02T13:16:00Z",
               originBoardId: 32
             })
  end
end
