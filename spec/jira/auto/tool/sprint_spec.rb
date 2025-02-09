# frozen_string_literal: true

module Jira
  module Auto
    # rubocop:disable Metrics/ClassLength
    class Tool
      # rubocop:disable RSpec/NestedGroups:
      RSpec.describe Sprint do
        let(:jira_client) { instance_double(JIRA::Client) }
        let(:tool) { instance_double(Tool, jira_client: jira_client) }
        let(:jira_sprint) do
          jira_resource_double(JIRA::Resource::Sprint,
                               id: 40_820,
                               name: "Food_Supply_24.4.5",
                               startDate: "2024-12-27 13:00 UTC", endDate: "2024-12-31 13:00 UTC",
                               state: state, originBoardId: 4096,
                               client: jira_client,
                               attrs: {})
        end

        let(:state) { "future" }

        context "when using its attributes" do
          let(:sprint) do
            described_class.new(tool, jira_sprint)
          end

          describe "#jira_client" do
            it { expect(sprint.jira_client).to eq(jira_client) }
          end

          describe "#id" do
            it { expect(sprint.id).to eq(40_820) }
          end

          describe "#name" do
            it { expect(sprint.name).to eq("Food_Supply_24.4.5") }
          end

          describe "#length_in_days" do
            it { expect(sprint.length_in_days).to eq(4) }
          end

          shared_examples "an optional date" do |date_method, jira_field:, expected_value:|
            it { expect(sprint.send(date_method)).to eq(Time.parse(expected_value).utc) }
            it { expect(sprint.send("#{date_method}?")).to be_truthy }

            context "when the sprint has no date" do
              before do
                allow(jira_sprint).to receive(:respond_to?).with(jira_field).and_return(false)
              end

              it("handles missing date information") { expect(sprint.send(date_method)).to eq(Sprint::UNDEFINED_DATE) }

              it { expect(sprint.send("#{date_method}?")).to be_falsy }
            end
          end

          describe "#start_date" do
            it_behaves_like "an optional date",
                            :start_date, jira_field: :startDate, expected_value: "2024-12-27 13:00 UTC"
          end

          describe "#start_date=" do
            it "can set the date attribute" do
              sprint.start_date = "2025-02-08 12:45 +0100"

              expect(jira_sprint.attrs["startDate"]).to eq("2025-02-08T11:45:00Z")
            end
          end

          describe "#end_date=" do
            it "can set the date attribute" do
              sprint.end_date = "2025-02-08 12:45 +0100"

              expect(jira_sprint.attrs["endDate"]).to eq("2025-02-08T11:45:00Z")
            end
          end

          describe "#end_date" do
            it_behaves_like "an optional date",
                            :end_date, jira_field: :endDate, expected_value: "2024-12-31 13:00 UTC"
          end

          describe "#missing_dates?" do
            def new_sprint(start_date: Sprint::UNDEFINED_DATE, end_date: Sprint::UNDEFINED_DATE)
              allow(sprint).to receive_messages(start_date: start_date, end_date: end_date)

              sprint
            end

            it { expect(new_sprint).to be_missing_dates }
            it { expect(new_sprint(start_date: Time.now)).to be_missing_dates }
            it { expect(new_sprint(end_date: Time.now.tomorrow)).to be_missing_dates }

            it { expect(new_sprint(start_date: Time.now, end_date: Time.now + 14.days)).not_to be_missing_dates }
          end

          describe "#state" do
            it { expect(sprint.state).to eq("future") }
          end

          describe "#closed?" do
            context "when the sprint state is closed" do
              let(:state) { "closed" }

              it { expect(sprint).to be_closed }
            end

            context "when the sprint state is active" do
              let(:state) { "active" }

              it { expect(sprint).not_to be_closed }
            end

            context "when the sprint state is future" do
              let(:state) { "future" }

              it { expect(sprint).not_to be_closed }
            end
          end

          describe "#origin_board_id" do
            it { expect(sprint.origin_board_id).to eq(4096) }
          end

          describe "#board" do
            let(:expected_board) { instance_double(Board, name: "Food_Supply_24.4.5") }

            before do
              allow(sprint).to receive(:origin_board_id).and_return(8192)

              allow(Board).to receive(:find_by_id).with(tool, 8192).and_return(expected_board)
            end

            it { expect(sprint.board).to eq(expected_board) }
          end

          describe "#renamed_to" do
            let(:jira_sprint) { jira_resource_double(JIRA::Resource::Sprint, name: "Food_Supply_24.4.5", state: state) }
            let(:state) { "future" }

            before do
              allow(jira_sprint).to receive_messages(save!: nil)
            end

            it "saves the sprint with the new name" do
              allow(sprint).to receive_messages(jira_sprint: jira_sprint)
              attrs = { name: "Food_Supply_25.4.1" }
              allow(jira_sprint).to receive_messages(attrs: attrs, save!: nil)
              allow(attrs).to receive(:[]=).with("name", "Food_Supply_25.4.1")

              sprint.rename_to("Food_Supply_25.4.1")

              expect(jira_sprint).to have_received(:save!)
            end

            it "ignores renaming to the same name" do
              sprint.rename_to("Food_Supply_24.4.5")

              expect(jira_sprint).not_to have_received(:save!)
            end

            context "when the sprint is closed" do
              let(:state) { "closed" }

              it "ignores renaming a closed sprint" do
                sprint.rename_to("Food_Supply_25.4.1")

                expect(jira_sprint).not_to have_received(:save!)
              end
            end
          end

          describe "#save" do
            it "saves the sprint" do
              allow(jira_sprint).to receive_messages(save!: nil, attrs: { "name" => "Food_Supply_25.4.1" })

              # allow(sprint).to receive_messages()

              sprint.save

              expect(jira_sprint).to have_received(:save!)
            end
          end

          describe "#to_table_row" do
            let(:board) do
              instance_double(Board, to_table_row: ["Food Supply Team Board", :url_to_suppply_team_board, "FOOD"])
            end

            before do
              allow(sprint).to receive_messages(board: board)
            end

            it do
              expect(sprint.to_table_row)
                .to eq([40_820, "Food_Supply_24.4.5", 4, "2024-12-27 13:00 UTC", "2024-12-31 13:00 UTC",
                        "Food Supply Team Board", :url_to_suppply_team_board, "FOOD"])
            end

            it "can exclude the board information" do
              expect(sprint.to_table_row(without_board_information: true))
                .to eq([40_820, "Food_Supply_24.4.5", 4, "2024-12-27 13:00 UTC", "2024-12-31 13:00 UTC"])
            end
          end

          describe ".to_table_row_field_names" do
            it {
              expect(described_class.to_table_row_field_names).to eq(%i[id name length_in_days start_date end_date])
            }
          end

          describe ".to_table_row_header" do
            before do
              allow(Board).to receive_messages(to_table_row_header: ["Name", "UI URL", "Project Key"])
            end

            it do
              expect(described_class.to_table_row_header)
                .to eq(["Id", "Name", "Length In Days", "Start Date", "End Date",
                        "Board Name", "Board UI URL", "Board Project Key"])
            end

            it "can exclude the board information" do
              expect(described_class.to_table_row_header(without_board_information: true))
                .to eq(["Id", "Name", "Length In Days", "Start Date", "End Date"])
            end
          end
        end

        describe "#<=>" do
          def new_sprint_named(name, start_date: "2024-12-30 13:00 UTC", end_date: "2025-01-14 13:00 UTC")
            # rubocop:disable RSpec/VerifiedDoubles
            described_class.new(
              tool,
              double(JIRA::Resource::Sprint, name: name, startDate: start_date, endDate: end_date,
                     originBoardId: 2048, inspect: name.inspect)
            )
            # rubocop:enable RSpec/VerifiedDoubles
          end

          let(:abc_sprint) { new_sprint_named("abc name_24.4.9") }
          let(:sprint_with_missing_date) do
            new_sprint_named("name that should not be last_24.4.9",
                             end_date: Sprint::UNDEFINED_DATE.utc.to_s)
          end

          it { expect(sprint_with_missing_date).to be < abc_sprint }

          it { expect(abc_sprint).to eq new_sprint_named("abc name_24.4.9") }
          it { expect(abc_sprint).to be < new_sprint_named("xyz name_24.4.9") }
          it { expect(new_sprint_named("def name_24.3.9")).to be > abc_sprint }

          it { expect(new_sprint_named("foo_bar_24.4.9")).to be < new_sprint_named("foo_bar_24.4.10") }

          it do
            expect(new_sprint_named("foo_bar_24.4.9", end_date: "2025-01-14 13:00 UTC"))
              .to be < new_sprint_named("foo_bar_24.4.9", end_date: "2025-01-15 13:00 UTC")
          end

          context "when sprint name does not respect the naming convention" do
            it { expect(abc_sprint).to be > new_sprint_named("1st sprint") }
            it { expect(abc_sprint).to be < new_sprint_named("name not following the naming conventions") }
          end
        end

        describe "#comparison_fields" do
          let(:sprint) { described_class.new(tool, jira_sprint) }

          before do
            allow(Sprint::Name).to receive_messages(respects_naming_convention?: respects_naming_convention)
          end

          context "when respecting the naming convention" do
            let(:respects_naming_convention) { true }

            it { expect(sprint.send(:comparison_fields, sprint)).to eq(%i[start_date end_date parsed_name]) }
          end

          context "when not respecting the naming convention" do
            let(:respects_naming_convention) { false }

            it { expect(sprint.send(:comparison_fields, sprint)).to eq(%i[start_date end_date name]) }
          end
        end

        describe ".date_for_save" do
          let(:now) { Time.now }

          it { expect(described_class.date_for_save(now)).to eq(now.utc.iso8601) }
          it do
            expect(described_class.date_for_save("2025-02-08 15:15:15 +0100").force_encoding("UTF-8")).
              to eq("2025-02-08T14:15:15Z")
          end

          it do
            expect { described_class.date_for_save(nil) }
              .to raise_error(ArgumentError, "nil (NilClass), date must be a Time, Date, DateTime or a String")
          end
        end
      end
      # rubocop:enable RSpec/NestedGroups:
    end

    # rubocop:enable Metrics/ClassLength
  end
end
