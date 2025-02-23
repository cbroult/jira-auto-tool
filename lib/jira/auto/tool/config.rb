# frozen_string_literal: true

require "fileutils"

module Jira
  module Auto
    class Tool
      class Config
        include Comparable

        attr_reader :tool

        def initialize(tool)
          @tool = tool
        end

        def []=(key, value)
          value_store[sanitize_key(key)] = value
          save
        end

        def [](key)
          value_store[sanitize_key(key)]
        end

        def key?(key)
          value_store.key?(sanitize_key(key))
        end

        def <=>(other)
          value_store <=> (other.is_a?(Config) ? other.value_store : other)
        end

        private

        def sanitize_key(key)
          key.to_s
        end

        def save
          File.write(path, value_store.to_yaml)
        end

        def value_store
          @value_store ||= load
        end

        def load
          File.exist?(path) ? YAML.safe_load_file(path) : {}
        end

        def path
          File.join(dir, "jira-auto-tool.config.yml")
        end

        def dir
          @dir ||=
            begin
              config_dir = File.join(Dir.home, ".config/jira-auto-tool")
              FileUtils.makedirs(config_dir)
              config_dir
            end
        end
      end
    end
  end
end
