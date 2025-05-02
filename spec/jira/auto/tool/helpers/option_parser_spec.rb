# frozen_string_literal: true

require "rspec"

require "jira/auto/tool/helpers/option_parser"

RSpec.describe OptionParser do
  let(:option_parser) { described_class.new([]) }

  describe ".section_header" do
    it do
      expect(option_parser).to receive(:on).with(<<~EOSB)

        a section name:
        ---------------
      EOSB

      option_parser.section_header("a section name")
    end
  end
end
