# frozen_string_literal: true

require "yaml"
require "fileutils"
require "jira/auto/tool/helpers/overridable_time"

module Jira
  module Auto
    class Tool
      class Board
        class Cache
          attr_reader :tool

          def initialize(tool)
            @tool = tool
          end

          def boards
            raise "This method should not be used since the cache is invalid" unless valid?

            @boards ||= raw_content.fetch("boards").collect { |board_id| Board.find_by_id(tool, board_id) }
          end

          def save(boards)
            File.write(file_path, { "boards" => boards.collect(&:id) }.to_yaml)

            boards
          end

          def clear
            FileUtils.rm_f(file_path)
          end

          def valid?
            File.exist?(file_path) && !expired?
          end

          private

          def expired?
            log.debug { "expired? #{cached_at} < #{one_hour_ago}" }

            cached_at < one_hour_ago
          end

          def one_hour_ago
            Helpers::OverridableTime.now - 1.hour
          end

          def cached_at
            File.mtime(file_path)
          end

          def raw_content
            YAML.safe_load_file(file_path) || {}
          end

          def file_path
            File.join(tool.config.dir, "jira-auto-tool.cache.yml")
          end
        end
      end
    end
  end
end
