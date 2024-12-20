# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/request_builder/sprint_state_updater"

RSpec.describe Jira::Auto::Tool::RequestBuilder::SprintStateUpdater do
  let(:sprint_creator) { described_class.new(jira_client, sprint: sprint_to_update, new_state: "closed") }

  let(:sprint_to_update) do
    instance_spy(JIRA::Resource::Sprint, id: 12_345, attrs: { id: 12_345, state: "open" })
  end

  let(:jira_client) { instance_spy(JIRA::Client).as_null_object }

  it { expect(sprint_creator.send(:request_url)).to eq("/rest/agile/1.0/sprint/12345") }

  it { expect(sprint_creator.send(:http_verb)).to eq(:put) }

  it do
    expect(sprint_creator.send(:request_payload))
      .to eq({
               id: 123_45,
               self: nil,
               name: nil,
               startDate: nil,
               endDate: nil,
               originBoardId: nil,
               state: "closed"
             })
  end
end
