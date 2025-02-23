# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      module Helpers
        class OverridableTime
          def self.now
            overridden_date_time = ENV.fetch("JAT_CURRENT_DATE_TIME", nil)
            log.debug { "JAT_CURRENT_DATE_TIME is set to #{overridden_date_time}" }

            (overridden_date_time ? Time.parse(overridden_date_time) : Time.now)
          end
        end
      end
    end
  end
end
