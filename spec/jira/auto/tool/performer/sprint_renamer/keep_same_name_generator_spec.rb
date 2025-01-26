# frozen_string_literal: true

require "rspec"

require "jira/auto/tool/performer/sprint_renamer/keep_same_name_generator"

RSpec.describe Jira::Auto::Tool::Performer::SprintRenamer::KeepSameNameGenerator do
  let(:keep_same_name_generator) { described_class.new }
  let(:sprint_name) { "random sprint name #{rand}" }

  it { expect(keep_same_name_generator.name_for(sprint_name)).to eq(sprint_name) }
end
