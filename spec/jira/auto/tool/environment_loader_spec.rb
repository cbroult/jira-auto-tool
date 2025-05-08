# frozen_string_literal: true

require "rspec"

module Jira
  module Auto
    class Tool
      # rubocop:disable Metrics/ClassLength
      class EnvironmentLoader
        RSpec.describe EnvironmentLoader do
          let(:environment_loader) { described_class.new(tool, auto_setup: auto_setup) }
          let(:auto_setup) { false }
          let(:tool) { instance_double(Tool, config: config) }
          let(:config) { instance_double(Config, dir: "config_dir", tool_name: "jira-auto-tool") }

          # rubocop:disable RSpec/AnyInstance
          describe "#initialize" do
            context "when auto_setup is true" do
              let(:auto_setup) { true }

              it do
                expect_any_instance_of(described_class).to receive(:setup)

                environment_loader
              end
            end

            context "when auto_setup is false" do
              let(:auto_setup) { false }

              it do
                expect_any_instance_of(described_class).not_to receive(:setup)

                environment_loader
              end
            end
          end
          # rubocop:enable RSpec/AnyInstance

          describe "#file_path" do
            before do
              allow(File).to receive(:exist?).with("./jira-auto-tool.env.yaml.erb")
                                             .and_return(current_directory_file_exists)
            end

            context "when file exists in current directory" do
              let(:current_directory_file_exists) { true }

              it { expect(environment_loader.file_path).to eq("./jira-auto-tool.env.yaml.erb") }
            end

            context "when file does not exist in current directory" do
              let(:current_directory_file_exists) { false }

              it { expect(environment_loader.file_path).to eq("config_dir/jira-auto-tool.env.yaml.erb") }
            end
          end

          describe "#tool_environment" do
            let(:environment_keys) { %i[JIRA_HOST JIRA_USER JIRA_PASSWORD] }

            before do
              allow(Environment).to receive(:constants).and_return(environment_keys)

              environment_keys.each do |environment_key|
                allow(ENV).to receive(:fetch).with(environment_key.to_s, nil).and_return("#{environment_key} value")
              end
            end

            it do
              expect(environment_loader.tool_environment).to eq(
                "JIRA_HOST" => "JIRA_HOST value",
                "JIRA_USER" => "JIRA_USER value",
                "JIRA_PASSWORD" => "JIRA_PASSWORD value"
              )
            end
          end

          describe "#create_file" do
            let(:logger) { instance_double(Logger) }

            before do
              allow(environment_loader)
                .to receive_messages(file_path: "file_path", example_file_path: "example_file_path", log: logger)

              allow(File).to receive(:exist?).with("file_path").and_return(file_path_exists)
            end

            context "when file does not exist" do
              let(:file_path_exists) { false }

              it "copies the example config file" do
                expect(FileUtils).to receive(:cp).with("example_file_path", "file_path")

                expect(logger).to receive(:info) do |&block|
                  expect(block.call).to eq(<<~EOCREATIONMESSAGE)
                    Created file file_path
                    _______________________________________________
                    TODO: Adjust the configuration to your context!
                  EOCREATIONMESSAGE
                end

                environment_loader.create_file
              end
            end

            context "when file already exists" do
              let(:file_path_exists) { true }

              it "does not copy the example config file if it already exists" do
                expect(logger).to receive(:error) do |&block|
                  expect(block.call).to eq(<<~EOEXPECTED_ERROR_MESSAGE)
                    Not overriding existing file_path
                    ______________________________________________
                    Please remove first before running this again!
                  EOEXPECTED_ERROR_MESSAGE
                end

                expect(Kernel).to receive(:exit).with(1)

                environment_loader.create_file
              end
            end
          end

          describe "#example_file_path" do
            before { allow(tool).to receive_messages(home_dir: "<JIRA_AUTO_TOOL_HOME_DIR>") }

            it "returns the path to the example config file" do
              expect(environment_loader.example_file_path)
                .to eq("<JIRA_AUTO_TOOL_HOME_DIR>/config/examples/jira-auto-tool.env.yaml.erb")
            end
          end

          describe "#setup" do
            before do
              allow(environment_loader).to receive_messages(file_path: "path/to/config/file.yaml")
              allow(environment_loader).to receive_messages(config_file_content: "file_content")
            end

            it "sets up the value according to the configuration file content" do
              allow(YAML)
                .to receive(:safe_load)
                .with("file_content")
                .and_return({ "a_key" => "a_value", "another_key" => "another_value", "yet_another_key" => 16 })

              expect(ENV).to receive(:[]=).with("a_key", "a_value")
              expect(ENV).to receive(:[]=).with("another_key", "another_value")
              expect(ENV).to receive(:[]=).with("yet_another_key", "16")

              environment_loader.send(:setup)
            end

            context "when the YAML parsing fails" do
              it "generates an error message including the file name" do
                allow(YAML).to receive(:safe_load)
                  .with("file_content")
                  .and_raise(RuntimeError, "could not find expected ':' at line 3 column 6)")

                expect { environment_loader.send(:setup) }
                  .to raise_error(RuntimeError, <<~EOEMSG
                    path/to/config/file.yaml:188: failed to load with the following error:
                    could not find expected ':' at line 3 column 6)
                  EOEMSG
                  )
              end
            end
          end

          describe "#config_file_content" do
            let(:file_path) { "path/to/config/file" }
            let(:file_content) do
              <<-YAML_ERB
                ---
                a_key: <%= 4*4 %>
                another_key: another_value
              YAML_ERB
            end

            let(:erb_result) do
              <<-YAML
                ---
                a_key: 16
                another_key: another_value
              YAML
            end

            before do
              allow(environment_loader).to receive_messages(file_path: file_path)
              allow(File).to receive(:exist?).with(file_path).and_return(true)
              allow(File).to receive(:read).with(file_path).and_return(file_content)
            end

            it { expect(environment_loader.send(:config_file_content)).to eq(erb_result) }

            context "when the ERB evaluation fails" do
              let(:file_content) do
                <<-YAML_ERB
                  ---
                  a_key: <%= 4*4 %>
                  another_key: <%= 4*4 %>
                  <%
                  raise "An error that should be caught and reported!"#{" "}
                  %>
                YAML_ERB
              end

              it "generates an error message including the file name" do
                expect { environment_loader.send(:config_file_content) }
                  .to raise_error(RuntimeError, <<~EOEMSG)
                    path/to/config/file:5: failed to load with the following error:
                    An error that should be caught and reported!
                  EOEMSG
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
