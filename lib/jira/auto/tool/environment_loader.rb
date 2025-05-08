# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class EnvironmentLoader
        attr_reader :tool

        def initialize(tool, auto_setup: true)
          @tool = tool

          setup if auto_setup
        end

        def create_file
          if File.exist?(file_path)
            log.error do
              <<~EOERRORMESSAGE
                Not overriding existing #{file_path}
                ______________________________________________
                Please remove first before running this again!
              EOERRORMESSAGE
            end

            Kernel.exit 1
          else
            FileUtils.cp(example_file_path, file_path)

            log.info do
              <<~EOMESSAGE
                Created file #{file_path}
                _______________________________________________
                TODO: Adjust the configuration to your context!
              EOMESSAGE
            end
          end
        end

        def list
          $stdout.puts <<~EOLIST
            #{configuration_source_string}
            #{table}
          EOLIST
        end

        def tool_environment
          Environment.constants.sort.to_h do |constant|
            constant_as_string = constant.to_s

            [constant_as_string, ENV.fetch(constant_as_string, nil)]
          end
        end

        def file_path
          File.exist?(current_dir_file_path) ? current_dir_file_path : config_dir_file_path
        end

        def example_file_path
          File.join(tool.home_dir, "config/examples", file_basename)
        end

        CURRENT_DIR = "."

        private

        def setup
          config_values.each { |key, value| ENV[key] = value.to_s }
        end

        def configuration_source_string
          if File.exist?(file_path)
            "Using configuration from #{file_path}"
          else
            <<~EOENV_ONLY
              Only using the environment variables since neither of the following files exist:
              #{current_dir_file_path}
              #{config_dir_file_path}
            EOENV_ONLY
          end
        end

        def config_values
          @config_values ||= YAML.safe_load(config_file_content) || {}
        rescue StandardError => e
          error_line = e.backtrace_locations.first.lineno
          message = <<~EOEMSG
            #{file_path}:#{error_line}: failed to load with the following error:
            #{e.message}
          EOEMSG

          log.error { message }
          raise message
        end

        def config_file_content
          @config_file_content ||= File.exist?(file_path) ? ERB.new(File.read(file_path)).result(binding) : ""
        rescue StandardError => e
          error_line = e.backtrace_locations.first.lineno

          message = <<~EOEMSG
            #{file_path}:#{error_line}: failed to load with the following error:
            #{e.message}
          EOEMSG

          log.error { message }

          raise message
        end

        def table
          Terminal::Table.new do |t|
            t.headings = %w[Name Value]
            t.rows = tool_environment.to_a
          end
        end

        def config
          tool.config
        end

        def config_dir_file_path
          File.join(config.dir, file_basename)
        end

        def current_dir_file_path
          File.join(CURRENT_DIR, file_basename)
        end

        def file_basename
          "#{config.tool_name}.env.yaml.erb"
        end
      end
    end
  end
end
