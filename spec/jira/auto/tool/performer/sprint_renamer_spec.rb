# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/performer/sprint_renamer"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Jira::Auto::Tool::Performer::SprintRenamer do
  let(:sprint_renamer) { described_class.new(tool, from_string, to_string) }
  let(:tool) { instance_double(Jira::Auto::Tool) }
  let(:from_string) { "25.1.5" }
  let(:to_string) { "25.2.1" }

  let(:sprint_prefixes) { %i[one_sprint_prefix another_sprint_prefix] }

  describe "#sprint_prefixes" do
    before do
      allow(tool).to receive_messages(unclosed_sprint_prefixes: sprint_prefixes)
    end

    it { expect(sprint_renamer.sprint_prefixes).to eq(sprint_prefixes) }
  end

  describe "#from_string_regex" do
    it { expect(sprint_renamer.from_string_regex).to eq(/25\.1\.5/) }
  end

  describe "#to_string" do
    it { expect(sprint_renamer.to_string).to eq("25.2.1") }
  end

  describe "#run" do
    it "rename the sprints for each sprint prefix" do
      allow(sprint_renamer).to receive_messages(sprint_prefixes: sprint_prefixes, rename_sprints_for_sprint_prefix: nil)

      sprint_renamer.run

      expect(sprint_renamer).to have_received(:rename_sprints_for_sprint_prefix).exactly(2).times
    end
  end

  describe "#rename_sprints_for_sprint_prefix" do
    def create_sprint(name)
      instance_double(Jira::Auto::Tool::Sprint, name: name, rename_to: nil)
    end

    let(:one_sprint) { create_sprint("a sprint name") }
    let(:another_sprint) { create_sprint("another sprint name") }

    let(:sprints) { [one_sprint, another_sprint] }

    let(:prefix) { instance_double(Jira::Auto::Tool::Sprint::Prefix, name: "Food_Delivery", sprints: sprints) }

    before do
      allow(sprint_renamer).to receive_messages(calculate_sprint_new_names: ["a new name", "another new name"])
    end

    it "renames each sprint" do
      sprint_renamer.rename_sprints_for_sprint_prefix(prefix)

      expect(sprints).to all have_received(:rename_to)
    end
  end

  describe "#calculate_sprint_new_names" do
    let(:sprint_names) do
      %w[
        Food_Delivery_25.1.2
        Food_Delivery_25.1.3
        Food_Delivery_25.1.4
        Food_Delivery_25.1.5
        Food_Delivery_25.2.1
        Food_Delivery_25.2.2
        Food_Delivery_25.2.3
        Food_Delivery_25.2.4
        Food_Delivery_25.2.5
      ]
    end

    context "when pulling a sprint into the previous planning interval" do
      let(:from_string) { "25.2.1" }
      let(:to_string) { "25.1.6" }

      let(:expected_new_sprint_names) do
        %w[
          Food_Delivery_25.1.2
          Food_Delivery_25.1.3
          Food_Delivery_25.1.4
          Food_Delivery_25.1.5
          Food_Delivery_25.1.6
          Food_Delivery_25.2.1
          Food_Delivery_25.2.2
          Food_Delivery_25.2.3
          Food_Delivery_25.2.4
        ]
      end

      it { expect(sprint_renamer.calculate_sprint_new_names(sprint_names)).to eq(expected_new_sprint_names) }
    end

    context "when renaming sprint forward inside planning interval" do
      let(:from_string) { "25.2.1" }
      let(:to_string) { "25.2.10" }

      let(:expected_new_sprint_names) do
        %w[
          Food_Delivery_25.1.2
          Food_Delivery_25.1.3
          Food_Delivery_25.1.4
          Food_Delivery_25.1.5
          Food_Delivery_25.2.10
          Food_Delivery_25.2.11
          Food_Delivery_25.2.12
          Food_Delivery_25.2.13
          Food_Delivery_25.2.14
        ]
      end

      it do
        expect(sprint_renamer.calculate_sprint_new_names(["Food_Delivery_25.1.5"]))
          .to eq(["Food_Delivery_25.1.5"])
      end

      it { expect(sprint_renamer.calculate_sprint_new_names(sprint_names)).to eq(expected_new_sprint_names) }
    end

    context "when renaming sprint backward inside planning interval" do
      let(:from_string) { "25.2.10" }
      let(:to_string) { "25.2.1" }

      let(:sprint_names) do
        %w[
          Food_Delivery_25.1.2
          Food_Delivery_25.1.3
          Food_Delivery_25.1.4
          Food_Delivery_25.1.5
          Food_Delivery_25.2.10
          Food_Delivery_25.2.11
          Food_Delivery_25.2.12
          Food_Delivery_25.2.13
          Food_Delivery_25.2.14
        ]
      end

      let(:expected_new_sprint_names) do
        %w[
          Food_Delivery_25.1.2
          Food_Delivery_25.1.3
          Food_Delivery_25.1.4
          Food_Delivery_25.1.5
          Food_Delivery_25.2.1
          Food_Delivery_25.2.2
          Food_Delivery_25.2.3
          Food_Delivery_25.2.4
          Food_Delivery_25.2.5
        ]
      end

      it do
        expect(sprint_renamer.calculate_sprint_new_names(["Food_Delivery_25.1.5"]))
          .to eq(["Food_Delivery_25.1.5"])
      end

      it { expect(sprint_renamer.calculate_sprint_new_names(sprint_names)).to eq(expected_new_sprint_names) }
    end

    context "when pushing a sprint to the next planning interval" do
      let(:expected_new_sprint_names) do
        %w[
          Food_Delivery_25.1.2
          Food_Delivery_25.1.3
          Food_Delivery_25.1.4
          Food_Delivery_25.2.1
          Food_Delivery_25.2.2
          Food_Delivery_25.2.3
          Food_Delivery_25.2.4
          Food_Delivery_25.2.5
          Food_Delivery_25.2.6
        ]
      end

      it { expect(sprint_renamer.calculate_sprint_new_names(["Food_Delivery_25.1.5"])).to eq(["Food_Delivery_25.2.1"]) }

      it { expect(sprint_renamer.calculate_sprint_new_names(sprint_names)).to eq(expected_new_sprint_names) }
    end

    context "when sprints exist beyond the immediate planning interval of the sprint" do
      let(:from_string) { "25.2.1" }
      let(:to_string) { "25.1.6" }

      let(:sprint_names) do
        %w[
          Food_Delivery_25.1.5
          Food_Delivery_25.2.1
          Food_Delivery_25.2.2
          Food_Delivery_25.3.1
          Food_Delivery_25.3.2
          Food_Delivery_25.3.3
        ]
      end

      let(:expected_new_sprint_names) do
        %w[
          Food_Delivery_25.1.5
          Food_Delivery_25.1.6
          Food_Delivery_25.2.1
          Food_Delivery_25.3.1
          Food_Delivery_25.3.2
          Food_Delivery_25.3.3
        ]
      end

      it "does not rename those sprints" do
        expect(sprint_renamer.calculate_sprint_new_names(sprint_names)).to eq(expected_new_sprint_names)
      end
    end
  end

  describe "#first_sprint_to_rename?" do
    let(:sprint_renamer) { described_class.new(nil, "25.1.5", "25.2.1") }

    def first_to_rename?(sprint_name)
      sprint_renamer.first_sprint_to_rename?(sprint_name)
    end

    it { expect(first_to_rename?("prefix_25.1.4")).not_to be_truthy }
    it { expect(first_to_rename?("prefix_25.1.5")).to be_truthy }
    it { expect(first_to_rename?("prefix_24.1.5")).not_to be_truthy }
    it { expect(first_to_rename?("prefix_25.2.1")).not_to be_truthy }
    it { expect(first_to_rename?("prefix_26.1.6")).not_to be_truthy }
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
