# frozen_string_literal: true

require_relative "tool/version"
require_relative "tool/sprint_generator"

module Jira
  module Sprint
    class Tool
      class Error < StandardError; end

      attr_accessor :board_name

      def sprint_generator
        @sprint_generator ||= SprintGenerator.new
      end
    end
  end
end
