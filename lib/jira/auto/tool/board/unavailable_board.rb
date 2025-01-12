# frozen_string_literal: true

module Jira
  module Auto
    class Tool
      class Board
        class UnavailableBoard < Board
          include Comparable

          attr_reader :id

          def initialize(tool, id)
            super(tool, JIRA::Resource::Board.new(id: id))
            @id = id
          end

          def name
            "N/A"
          end

          def url
            "N/A"
          end

          def ui_url
            "N/A"
          end

          def <=>(other)
            id <=> other.id
          end
        end
      end
    end
  end
end
