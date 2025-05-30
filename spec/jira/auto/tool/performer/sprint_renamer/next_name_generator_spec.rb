# frozen_string_literal: true

require "rspec"

require "jira/auto/tool/performer/sprint_renamer/next_name_generator"

RSpec.describe Jira::Auto::Tool::Performer::SprintRenamer::NextNameGenerator do
  def parsed_name(sprint_name)
    Jira::Auto::Tool::Sprint::Name.parse(sprint_name)
  end

  describe "#new_name_of_sprint_next_to_first_renamed_sprint" do
    subject(:new_name) { next_name_generator.new_name_of_sprint_next_to_first_renamed_sprint }

    let(:next_name_generator) do
      described_class.new(original_name_of_first_renamed_sprint, name_of_first_renamed_sprint)
    end

    context "when pulling sprint into previous planning interval" do
      let(:original_name_of_first_renamed_sprint) { "prefix_23.2.1" }
      let(:name_of_first_renamed_sprint) { "prefix_23.1.6" }

      it("returns the original sprint name") { expect(new_name).to eq(parsed_name("prefix_23.1.7")) }
    end

    context "when renaming inside planning interval" do
      let(:original_name_of_first_renamed_sprint) { "prefix_23.2.1" }
      let(:name_of_first_renamed_sprint) { "prefix_23.2.4" }

      it { expect(new_name).to eq(parsed_name("prefix_23.2.5")) }
    end

    context "when pushing sprint into next planning interval" do
      let(:original_name_of_first_renamed_sprint) { "prefix_23.1.5" }
      let(:name_of_first_renamed_sprint) { "prefix_23.2.2" }

      it("returns the original sprint parsed name") { expect(new_name).to eq(parsed_name("prefix_23.2.3")) }
    end
  end

  describe "#pulling_sprint_into_previous_planning_interval?" do
    let(:next_name_generator) do
      described_class.new(original_name_of_first_renamed_sprint, name_of_first_renamed_sprint)
    end

    context "when sprint goes to the preceding planning interval" do
      let(:original_name_of_first_renamed_sprint) { "prefix_26.1.1" }
      let(:name_of_first_renamed_sprint) { "prefix_25.2.1" }

      it { expect(next_name_generator).to be_pulling_sprint_into_previous_planning_interval }
    end

    context "when sprint is renamed backward inside the current preceding planning interval" do
      let(:original_name_of_first_renamed_sprint) { "prefix_26.1.4" }
      let(:name_of_first_renamed_sprint) { "prefix_26.1.1" }

      it { expect(next_name_generator).not_to be_pulling_sprint_into_previous_planning_interval }
    end

    context "when sprint is renamed forward inside the current planning interval" do
      let(:original_name_of_first_renamed_sprint) { "prefix_26.1.1" }
      let(:name_of_first_renamed_sprint) { "prefix_26.1.4" }

      it { expect(next_name_generator).not_to be_pulling_sprint_into_previous_planning_interval }
    end

    context "when sprint goes to the following planning interval" do
      let(:original_name_of_first_renamed_sprint) { "prefix_25.1.5" }
      let(:name_of_first_renamed_sprint) { "prefix_25.2.1" }

      it { expect(next_name_generator).not_to be_pulling_sprint_into_previous_planning_interval }
    end
  end

  describe "#next_name_in_planning_interval" do
    let(:name_generator) { described_class.new(original_name_of_first_renamed_sprint, name_of_first_renamed_sprint) }
    let(:next_names) { 4.times.collect { name_generator.next_name_in_planning_interval } }

    context "when pulling to the previous planning interval" do
      let(:original_name_of_first_renamed_sprint) { "prefix_25.2.1" }
      let(:name_of_first_renamed_sprint) { "prefix_25.1.8" }

      it "generates a new name consecutive to the previous one in the planning interval" do
        expect(next_names).to eq(%w[prefix_25.1.9 prefix_25.1.10 prefix_25.1.11 prefix_25.1.12])
      end
    end

    context "when renaming in the same planning interval" do
      let(:original_name_of_first_renamed_sprint) { "prefix_25.1.5" }
      let(:name_of_first_renamed_sprint) { "prefix_25.1.20" }

      it "generates a new name consecutive to the previous one in the planning interval" do
        expect(next_names).to eq(%w[prefix_25.1.21 prefix_25.1.22 prefix_25.1.23 prefix_25.1.24])
      end
    end

    context "when pushing to the next planning interval" do
      let(:original_name_of_first_renamed_sprint) { "prefix_25.1.5" }
      let(:name_of_first_renamed_sprint) { "prefix_25.2.1" }

      it "generates a new name consecutive to the previous one in the planning interval" do
        expect(next_names).to eq(%w[prefix_25.2.2 prefix_25.2.3 prefix_25.2.4 prefix_25.2.5])
      end
    end
  end

  describe "#name_for" do
    let(:name_generator) { described_class.new(original_name_of_first_renamed_sprint, name_of_first_renamed_sprint) }
    let(:original_name_of_first_renamed_sprint) { "prefix_25.2.1" }
    let(:name_of_first_renamed_sprint) { "prefix_25.1.8" }

    context "when sprint name inside the planning interval" do
      before do
        allow(name_generator).to receive_messages(next_name_in_planning_interval: "next_name_in_planning_interval")
      end

      it { expect(name_generator.name_for("prefix_25.2.2")).to eq("next_name_in_planning_interval") }
    end

    context "when sprint name outside planning interval" do
      let(:original_name_of_first_renamed_sprint) { "prefix_25.1.5" }
      let(:name_of_first_renamed_sprint) { "prefix_25.2.20" }

      it "generates a new name consecutive to the previous one in the planning interval" do
        expect(name_generator.name_for("prefix_25.3.2")).to eq("prefix_25.2.21")
      end
    end
  end
end
