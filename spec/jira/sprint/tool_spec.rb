# frozen_string_literal: true

RSpec.describe Jira::Sprint::Tool do
  it "has a version number" do
    expect(Jira::Sprint::Tool::VERSION).not_to be_nil
  end
end
