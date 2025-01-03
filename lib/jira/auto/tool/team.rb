# frozen_string_literal: true

require "jira/auto/tool"

module Jira
  module Auto
    class Tool
      class Team
        def initialize(field_option)
          @field_option = field_option
        end

        def name
          @field_option.value
        end

        def id
          @field_option.id
        end
      end
    end
  end
end
