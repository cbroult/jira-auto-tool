# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/performer/sprint_renamer"

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

      it do
        expect(sprint_renamer.calculate_sprint_new_names(["Food_Delivery_25.1.5"])).to eq(["Food_Delivery_25.2.1"])
      end

      it { expect(sprint_renamer.calculate_sprint_new_names(sprint_names)).to eq(expected_new_sprint_names) }
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

    context "when sprints exist beyond the immediate planning interval of the sprint" do
      let(:from_string) { "25.2.1" }
      let(:to_string) { "25.1.6" }

      let(:sprint_names) do
        %w[
          Food_Delivery_25.1.2
          Food_Delivery_25.1.3
          Food_Delivery_25.1.4
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
          Food_Delivery_25.1.2
          Food_Delivery_25.1.3
          Food_Delivery_25.1.4
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

  def get_parsed_name(sprint_name)
    Jira::Auto::Tool::Sprint::Name.parse(sprint_name)
  end

  describe "#beyond_planning_interval_of_sprint_next_to_initially_renamed_sprint" do
    def beyond?(sprint_name)
      described_class.new(nil, "", "")
                     .beyond_planning_interval_of_sprint_next_to_initially_renamed_sprint(
                       sprint_name, parsed_name_of_sprint_next_to_initially_renamed_sprint
                     )
    end

    context "when parsed_name_of_sprint_next_to_initially_renamed_sprint not defined" do
      let(:parsed_name_of_sprint_next_to_initially_renamed_sprint) { nil }

      it { expect(beyond?("prefix_25.2.1")).not_to be_truthy }
      it { expect(beyond?("prefix_25.3.1")).not_to be_truthy }
    end

    context "when pushing_sprint_to_next_planning_interval? returns true" do
      let(:parsed_name_of_sprint_next_to_initially_renamed_sprint) { get_parsed_name("prefix_25.2.2") }

      it { expect(beyond?("prefix_25.2.1")).not_to be_truthy }
      it { expect(beyond?("prefix_25.2.3")).not_to be_truthy }
      it { expect(beyond?("prefix_25.3.1")).to be_truthy }
      it { expect(beyond?("prefix_25.3.2")).to be_truthy }
      it { expect(beyond?("prefix_25.4.2")).to be_truthy }
      it { expect(beyond?("prefix_26.1.1")).to be_truthy }
    end

    context "when pushing_sprint_to_next_planning_interval? returns false" do
      let(:parsed_name_of_sprint_next_to_initially_renamed_sprint) { get_parsed_name("prefix_25.2.1") }

      it { expect(beyond?("prefix_25.2.1")).not_to be_truthy }
      it { expect(beyond?("prefix_25.2.3")).not_to be_truthy }
      it { expect(beyond?("prefix_25.3.1")).to be_truthy }
      it { expect(beyond?("prefix_25.3.2")).to be_truthy }
      it { expect(beyond?("prefix_25.4.2")).to be_truthy }
      it { expect(beyond?("prefix_26.1.1")).to be_truthy }
    end
  end

  describe "#initial_next_sprint_parsed_name" do
    subject(:result) do
      described_class.new(nil, "", "").initial_next_sprint_parsed_name(sprint_name, sprint_new_name)
    end

    let(:sprint_name) { "prefix_23.2.1" } # Valid sprint name format based on Name class regex
    let(:sprint_new_name) { "prefix_23.2.2" } # Next sprint name
    let(:parsed_sprint_name) { get_parsed_name(sprint_name) }
    let(:parsed_sprint_new_name) { get_parsed_name(sprint_new_name) }

    context "when pushing_sprint_to_next_planning_interval? returns true" do
      before do
        allow_any_instance_of(described_class).to receive(:pushing_sprint_to_next_planning_interval?)
          .with(parsed_sprint_name, parsed_sprint_new_name).and_return(true)
      end

      it "returns the next sprint in the planning interval" do
        expect(result).to eq(parsed_sprint_new_name.next_in_planning_interval)
      end
    end

    context "when pushing_sprint_to_next_planning_interval? returns false" do
      before do
        allow_any_instance_of(described_class).to receive(:pushing_sprint_to_next_planning_interval?)
          .with(parsed_sprint_name, parsed_sprint_new_name).and_return(false)
      end

      it "returns the original sprint parsed name" do
        expect(result).to eq(parsed_sprint_name)
      end
    end
  end

  describe "#pushing_sprint_to_next_planning_interval?" do
    let(:sprint_renamer) { described_class.new(nil, "", "") }

    context "when current sprint name is less than new sprint name" do
      it "returns true" do
        sprint_parsed_name = double("Sprint::Name", :< => true)
        sprint_parsed_new_name = double("Sprint::Name")

        expect(sprint_renamer.pushing_sprint_to_next_planning_interval?(sprint_parsed_name,
                                                                        sprint_parsed_new_name)).to be true
      end
    end

    context "when current sprint name is not less than new sprint name" do
      it "returns false" do
        sprint_parsed_name = double("Sprint::Name", :< => false)
        sprint_parsed_new_name = double("Sprint::Name")

        expect(sprint_renamer.pushing_sprint_to_next_planning_interval?(sprint_parsed_name,
                                                                        sprint_parsed_new_name)).to be false
      end
    end
  end
end
