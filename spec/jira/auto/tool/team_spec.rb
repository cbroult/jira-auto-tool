# frozen_string_literal: true

require "rspec"

require "jira/auto/tool/team"

module Jira
  module Auto
    class Tool
      class Team
        RSpec.describe Team do
          let(:team) { described_class.new(field_option) }
          let(:field_option) { instance_double(FieldOption, id: 123, value: "Test Team") }

          it { expect(team.name).to eq("Test Team") }
          it { expect(team.id).to eq(123) }
        end
      end
    end
  end
end
