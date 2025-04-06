# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class Config
        class Options
          def self.add(_tool, parser)
            parser.on
            parser.on("Config options:")

            parser.on("--config-list") do
              # TODO: tool.config.list
            end
          end
        end
      end
    end
  end
end
