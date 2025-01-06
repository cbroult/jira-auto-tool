# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      module Helpers
        module EnvironmentBasedValue
          # rubocop:disable Metrics/MethodLength
          def define_overridable_environment_based_value(method_name)
            attr_writer method_name

            define_method(method_name) do
              instance_variable_name = "@#{method_name}"

              instance_variable_get(instance_variable_name) ||
                instance_variable_set(instance_variable_name,
                                      self.class.fetch_corresponding_environment_variable(method_name.to_s))
            end

            define_method(:"#{method_name}_defined?") do
              self.class.corresponding_environment_variable_defined?(method_name.to_s)
            end

            constant_name = method_name.to_s.upcase
            class_eval <<-EOCONSTANT, __FILE__, __LINE__ + 1
              # This module and constant will be interpolated as follows:
              # module Environment
              #   CONSTANT_NAME = "CONSTANT_NAME"
              # end
              module Environment
                 #{constant_name} = #{constant_name.inspect}
              end
            EOCONSTANT
          end
          # rubocop:enable Metrics/MethodLength

          def fetch_corresponding_environment_variable(caller_method_name = caller_locations(1, 1).first.base_label)
            environment_variable_name = caller_method_name.upcase

            log.info { "fetch_corresponding_environment_variable(#{environment_variable_name})" }

            ENV.fetch(environment_variable_name) { |name| raise KeyError, "Missing #{name} environment variable!" }
          end

          def corresponding_environment_variable_defined?(caller_method_name = caller_locations(1, 1).first.base_label)
            environment_variable_name = caller_method_name.upcase

            log.info { "corresponding_environment_variable_defined?(#{environment_variable_name})" }

            ENV.key?(environment_variable_name)
          end
        end
      end
    end
  end
end
