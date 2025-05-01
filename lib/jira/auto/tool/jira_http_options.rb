# frozen_string_literal: true

require "jira/auto/tool"

module Jira
  module Auto
    class Tool
      module JiraHttpOptions
        DISPLAY_HELP_OPTION = "--help"

        def self.add(tool, parser)
          parser.on("--[no-]jira-http-debug", "Enable or disable HTTP debug mode") do |v|
            tool.jira_http_debug = v
          end
        end
      end
    end
  end
end
