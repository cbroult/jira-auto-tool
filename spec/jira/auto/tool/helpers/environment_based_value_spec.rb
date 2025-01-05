# frozen_string_literal: true

require "rspec"

module Jira
  module Auto
    class Tool
      module Helpers
        module EnvironmentBasedValue
          RSpec.describe "EnvironmentBasedValue" do
            context "when condition" do
              it "succeeds" do
                expect(true).to be_truthy # TODO
              end
            end
          end
        end
      end
    end
  end
end
