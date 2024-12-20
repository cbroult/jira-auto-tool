# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class SprintGenerator
        attr_accessor :iteration_count,
                      :iteration_index_start,
                      :iteration_length_in_days,
                      :iteration_prefix,
                      :start_date_time
      end
    end
  end
end
