# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/common_options"

module Jira
  module Auto
    class Tool
      module CommonOptions
        RSpec.describe CommonOptions do
          describe ".add" do
            let(:tool) { Tool.new }
            let(:parser) { OptionParser.new }

            before do
              allow(EnvironmentLoader).to receive_messages(new: instance_double(EnvironmentLoader))
              described_class.add(tool, parser)
            end

            context "when using --help" do
              it do
                expect(Kernel).to receive(:puts).with(parser)
                expect(Kernel).to receive(:exit).with(1)

                parser.parse(["--help"])
              end
            end

            context "when using --version" do
              it do
                expect(Kernel).to receive(:puts).with(tool.class::VERSION)
                expect(Kernel).to receive(:exit).with(1)

                parser.parse(["--version"])
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
          end
        end
      end
    end
  end
end
