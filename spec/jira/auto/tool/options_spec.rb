# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/options"

module Jira
  module Auto
    class Tool
      module Options
        RSpec.describe Options do
          describe ".add" do
            let(:tool) { instance_double(Tool) }
            let(:parser) { OptionParser.new }

            before { described_class.add(tool, parser) }

            context "when configuring --help" do
              it do
                expect(Kernel).to receive(:puts).with(parser)
                expect(Kernel).to receive(:exit).with(1)

                parser.parse(["--help"])
              end
            end

            # TODO: define proper tests
            def expect_option_use_to_be_valid(option_use_with_args)
              expect do
                parser.parse([option_use_with_args])
              end.not_to raise_error
            end

            it { expect_option_use_to_be_valid(["--help"]) }
            it { expect_option_use_to_be_valid(["-h"]) }
            it { expect_option_use_to_be_valid(["--jira-http-debug"]) }
            it { expect_option_use_to_be_valid(["--jira-http-debug=false"]) }
            it { expect_option_use_to_be_valid(["--no-jira-http-debug"]) }
          end
        end
      end
    end
  end
end
