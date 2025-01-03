# frozen_string_literal: true

require "jira/auto/tool/field_option"

module Jira
  module Auto
    class Tool
      class FieldOption
        RSpec.describe FieldOption do
          let(:jira_client) { instance_double(JIRA::Client) }
          let(:field_option) { described_class.new(jira_client, 123, "Test Option") }

          describe "#initialize" do
            it "assigns the id correctly" do
              expect(field_option.id).to eq(123)
            end

            it "assigns the value correctly" do
              expect(field_option.value).to eq("Test Option")
            end
          end

          describe "#to_s" do
            it "returns the correct string representation" do
              expect(field_option.to_s).to eq("FieldOption(id: 123, value: 'Test Option')")
            end
          end

          describe "#<=>" do
            let(:higher_field_option) { described_class.new(jira_client, 124, "Another Option") }
            let(:lower_field_option) { described_class.new(jira_client, 122, "Previous Option") }
            let(:equal_field_option) { described_class.new(jira_client, 123, "Test Option") }

            it { expect(field_option).to be < higher_field_option }
            it { expect(field_option).to be > lower_field_option }
            it { expect(field_option).to eq(equal_field_option) }
          end
        end
      end
    end
  end
end
