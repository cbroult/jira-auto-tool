# frozen_string_literal: true

require_relative "../sprint"

module Jira
  module Auto
    class Tool
      class Sprint
        class Prefix
          include Comparable

          attr_reader :name, :sprints

          def initialize(name, sprints = [])
            @name = name
            @sprints = sprints
          end

          def <<(sprint)
            @sprints << sprint
          end

          def to_s
            "name: #{name}, sprints: #{sprints}"
          end

          def last_sprint
            sprints.max
          end

          def <=>(other)
            [name, sprints] <=> [other.name, other.sprints]
          end
        end
      end
    end
  end
end
