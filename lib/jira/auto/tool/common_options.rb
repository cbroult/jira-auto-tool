# frozen_string_literal: true

require "jira/auto/tool/helpers/option_parser"

module Jira
  module Auto
    class Tool
      module CommonOptions
        DISPLAY_HELP_OPTION = "--help"

        def self.add(tool, parser)
          ::ARGV << DISPLAY_HELP_OPTION if ARGV.empty?

          parser.section_header "Common"

          add_help_banner_and_options(parser)
          add_version_options(parser, tool)
        end

        def self.add_help_banner_and_options(parser)
          parser.banner = <<~EOBANNER
            Usage: #{File.basename($PROGRAM_NAME)} [options]*
          EOBANNER

          parser.on("-h", DISPLAY_HELP_OPTION, "Print this help") do
            Kernel.puts parser
            Kernel.exit 1
          end
        end

        def self.add_version_options(parser, tool)
          parser.on("-v", "--version", "Print the version") do
            Kernel.puts tool.class::VERSION

            Kernel.exit 1
          end
        end
      end
    end
  end
end
