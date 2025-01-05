# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      module Helpers
        module EnvironmentBasedValue
          def define_overridable_environment_based_value(method_name)
            attr_writer method_name

            define_method(method_name) do
              instance_variable_name = "@#{method_name}"

              instance_variable_get(instance_variable_name) ||
                instance_variable_set(instance_variable_name,
                                      self.class.fetch_corresponding_environment_variable(method_name.to_s))
            end
          end

          def fetch_corresponding_environment_variable(caller_method_name = caller_locations(1, 1).first.base_label)
            environment_variable_name = caller_method_name.upcase

            log.info { "fetch_corresponding_environment_variable(#{environment_variable_name})" }

            ENV.fetch(environment_variable_name) { |name| raise KeyError, "Missing #{name} environment variable!" }
          end
        end
      end
    end
  end
end
