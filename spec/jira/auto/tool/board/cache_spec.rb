# frozen_string_literal: true

require "rspec"

require "jira/auto/tool/board/cache"

module Jira
  module Auto
    class Tool
      class Board
        class Cache
          RSpec.describe Cache do
            let(:cache) { described_class.new(tool) }
            let(:tool) { instance_double(Tool) }

            describe "#boards" do
              before { allow(cache).to receive_messages(valid?: valid?) }

              context "when cache is valid" do
                let(:valid?) { true }

                before do
                  allow(cache).to receive_messages(raw_content: { "boards" => [1, 2] })
                  allow(Board).to receive(:find_by_id).with(tool, 1).and_return(:first_board)
                  allow(Board).to receive(:find_by_id).with(tool, 2).and_return(:second_board)
                end

                it "returns the boards" do
                  expect(cache.boards).to eq(%i[first_board second_board])
                end
              end

              context "when cache is invalid" do
                let(:valid?) { false }

                it do
                  expect { cache.boards }
                    .to raise_error(RuntimeError, "This method should not be used since the cache is invalid")
                end
              end
            end

            describe "#save" do
              let(:boards) { [4, 8].collect { |id| instance_double(Board, id: id) } }

              before do
                allow(cache).to receive_messages(file_path: "path/to/cache.yml")
              end

              it "returns the boards" do
                expect(File).to receive(:write).with("path/to/cache.yml", { "boards" => [4, 8] }.to_yaml)

                expect(cache.save(boards)).to eq(boards)
              end
            end

            describe "#clear" do
              before do
                allow(cache).to receive_messages(file_path: "path/to/cache.yml")
                allow(FileUtils).to receive(:rm_f).with("path/to/cache.yml")
              end

              it "deletes the cache file" do
                cache.clear

                expect(FileUtils).to have_received(:rm_f).with("path/to/cache.yml")
              end
            end

            describe "#valid?" do
              before do
                allow(cache).to receive_messages(file_path: "path/to/cache.yml")

                allow(File).to receive(:exist?).with("path/to/cache.yml").and_return(exist?)
              end

              context "when cache file exists" do
                let(:exist?) { true }

                before do
                  allow(cache).to receive_messages(expired?: expired?)
                end

                context "when cache has not expired" do
                  let(:expired?) { false }

                  it { expect(cache).to be_valid }
                end

                context "when cache has expired" do
                  let(:expired?) { true }

                  it { expect(cache).not_to be_valid }
                end
              end
            end

            describe "#expired?" do
              before do
                allow(cache).to receive_messages(cached_at: cached_at)
              end

              context "when expired" do
                let(:cached_at) { Time.now - 1.hour }

                it { expect(cache.send(:expired?)).to be_truthy }
              end

              context "when not expired" do
                let(:cached_at) { Time.now }

                it { expect(cache.send(:expired?)).to be_falsy }
              end
            end

            describe "#one_hour_ago" do
              let(:time_now) { Time.parse("2025-02-21 20:55:00 UTC") }

              before { allow(Helpers::OverridableTime).to receive_messages(now: time_now) }

              it { expect(cache.send(:one_hour_ago)).to eq(Time.parse("2025-02-21 19:55:00 UTC")) }
            end

            describe "#file_path" do
              let(:config) { instance_double(Config, dir: "path/to/config/dir") }

              before do
                allow(tool).to receive_messages(config: config)
              end

              it "is located in the config dir" do
                expect(cache.send(:file_path)).to eq("path/to/config/dir/jira-auto-tool.cache.yml")
              end
            end
          end
        end
      end
    end
  end
end
