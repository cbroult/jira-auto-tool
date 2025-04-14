# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      module Helpers
        module Pagination
          PAGE_SIZE = 50

          def self.fetch_all_object_pages(parameter_naming_convention = :camelCase)
            all_objects = []
            start_at = 0

            loop do
              pagination_options = build_pagination_options(parameter_naming_convention, PAGE_SIZE, start_at)

              log.debug { "Fetching objects from Jira (#{pagination_options.inspect})..." }

              fetched_objects = yield(pagination_options)

              log.debug { "Fetched #{fetched_objects.size} object." }

              all_objects.concat(fetched_objects)

              start_at += PAGE_SIZE

              break if fetched_objects.empty?
            end

            log.debug { all_objects.collect(&:name).join(", ") }

            all_objects
          end

          def self.build_pagination_options(parameter_naming_convention, max_results, start_at)
            PAGINATION_PARAMETER_STYLES
              .fetch(parameter_naming_convention) { |k| "#{k.inspect}: not found in #{PAGINATION_PARAMETER_STYLES}" }
              .zip([max_results, start_at])
              .to_h
          end

          PAGINATION_PARAMETER_STYLES = {
            camelCase: %i[maxResults startAt],
            snake_case: %i[max_results start_at]
          }.freeze
        end
      end
    end
  end
end
