# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      module Helpers
        module EnvironmentBasedValue
          def define_overridable_environment_based_value(method_name)
            attr_writer method_name

            define_fetcher(method_name)
            define_predicate(method_name)
            define_reader_accepting_default_value(method_name)
            define_environment_variable_name_constant(method_name)
          end

          def fetch_corresponding_environment_variable(caller_method_name = caller_locations(1,
                                                                                             1).first.base_label)
            environment_variable_name = caller_method_name.upcase

            value = ENV.fetch(environment_variable_name) do |name|
              raise KeyError, "Missing #{name} environment variable!"
            end

            log.debug { "fetch_corresponding_environment_variable(#{environment_variable_name}) - #{value.inspect}" }

            value
          end

          def define_fetcher(method_name)
            define_method(method_name) do
              instance_variable_name = "@#{method_name}"

              instance_variable_get(instance_variable_name) ||
                instance_variable_set(instance_variable_name,
                                      self.class.fetch_corresponding_environment_variable(method_name.to_s))
            end
          end

          def define_predicate(method_name)
            define_method(:"#{method_name}_defined?") do
              self.class.corresponding_environment_variable_defined?(method_name.to_s)
            end
          end

          def define_reader_accepting_default_value(method_name)
            define_method(:"#{method_name}_when_defined_else") do |value|
              if self.class.corresponding_environment_variable_defined?(method_name.to_s)
                send(method_name)
              else
                value
              end
            end
          end

          def define_environment_variable_name_constant(method_name)
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
