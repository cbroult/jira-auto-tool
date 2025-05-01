# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/jira_http_options"

module Jira
  module Auto
    class Tool
      module JiraHttpOptions
        RSpec.describe JiraHttpOptions do
          describe ".add" do
            let(:tool) { instance_double(Tool) }
            let(:parser) { OptionParser.new }

            before { described_class.add(tool, parser) }

            # TODO: define proper tests
            def expect_option_use_to_be_valid(option_use_with_args)
              expect do
                parser.parse([option_use_with_args])
              end.not_to raise_error
            end

            it { expect_option_use_to_be_valid(["--jira-http-debug"]) }
            it { expect_option_use_to_be_valid(["--jira-http-debug=false"]) }
            it { expect_option_use_to_be_valid(["--no-jira-http-debug"]) }
          end
        end
      end
    end
  end
end
