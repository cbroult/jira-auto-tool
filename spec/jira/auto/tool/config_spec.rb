# frozen_string_literal: true

require "rspec"
require "jira/auto/tool/config"

module Jira
  module Auto
    class Tool
      class Config
        RSpec.describe Config do
          let(:config) { described_class.new(tool) }
          let(:tool) { instance_double(Tool) }

          describe "#[]" do
            it "returns the value of the key" do
              allow(config).to receive_messages(value_store: { "key" => "value" })

              expect(config[:key]).to eq("value")
            end
          end

          describe "#[]=" do
            before do
              allow(config).to receive_messages(value_store: { "one_key" => "a_value" }, save: nil)
            end

            it "updates the value and saves the configuration" do
              config[:key] = "value"

              expect(config[:key]).to eq("value")
              expect(config).to have_received(:save)
            end
          end

          describe "#key?" do
            before do
              allow(config).to receive_messages(value_store: { "one_key" => "a_value" }, save: nil)
            end

            it { expect(config).to be_key(:one_key) }
            it { expect(config).not_to be_key(:inexistent_key) }
          end

          describe "#load" do
            let(:config_path) { "config-path" }

            before do
              allow(config).to receive_messages(path: config_path)
              allow(File).to receive(:exist?).with(config_path).and_return(config_path_exists?)
              allow(YAML).to receive(:safe_load_file).with(config_path).and_return(:config_values)
            end

            context "when the file exists" do
              let(:config_path_exists?) { true }

              it "loads the configuration from the file" do
                config.send(:load)

                expect(config).to eq(:config_values)
              end
            end

            context "when the file does not exists" do
              let(:config_path_exists?) { false }

              it { expect(config).to eq({}) }
            end
          end

          describe "#save" do
            it "writes the configuration as yaml to the file" do
              allow(config).to receive_messages(path: "config.yml", value_store: { key: "value" })
              allow(File).to receive_messages(write: nil)

              config.send(:save)

              expect(File).to have_received(:write).with("config.yml", "---\n:key: value\n")
            end
          end

          describe "#path" do
            before do
              allow(config).to receive_messages(dir: "path/to/config_dir")
            end

            it { expect(config.send(:path)).to eq("path/to/config_dir/jira-auto-tool.config.yml") }
          end

          describe "#dir" do
            let(:expected_dir) { "~/.config/jira-auto-tool" }

            before do
              allow(Dir).to receive_messages(home: "~/")
            end

            it { expect(config.send(:dir)).to eq(expected_dir) }

            it "creates the directory if it does not exist" do
              expect(FileUtils).to receive(:makedirs).with(expected_dir)

              config.send(:dir)
            end
          end
        end
      end
    end
  end
end
