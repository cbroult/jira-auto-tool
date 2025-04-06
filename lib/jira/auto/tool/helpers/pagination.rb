# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      module Helpers
        module Pagination
          PAGE_SIZE = 50

          def self.fetch_all_object_pages
            all_objects = []
            start_at = 0

            loop do
              pagination_options = { maxResults: PAGE_SIZE, startAt: start_at }

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
        end
      end
    end
  end
end
