# frozen_string_literal: true

module Jira
  module Sprint
    class Tool
      class SprintGenerator
        module Options
          def self.add(sprint_generator, parser)
            parser.on("--sprint-generator-iteration-count=NUMBER", Integer,
                      "The number of sprints to generate") do |iteration_count|
              sprint_generator.iteration_count = iteration_count
            end

            parser.on("--sprint-generator-iteration-index-start=NUMBER", Integer,
                      "Index of the first sprint that is going to be generated in the quarter.") do |start|
              sprint_generator.iteration_index_start = start
            end

            parser.on("--sprint-generator-iteration-length-in-days=NUMBER",
                      Integer,
                      "Those days are going to be used to calculate the sprint end date") do |iteration_length_in_days|
              sprint_generator.iteration_length_in_days = iteration_length_in_days
            end

            parser.on("--sprint-generator-iteration-prefix=STRING", String) do |prefix|
              sprint_generator.iteration_prefix = prefix
            end

            parser.on("--sprint-generator-start-date_time=DATE_TIME", DateTime,
                      "Specify the start and time of the sprint to be created") do |date_time|
              sprint_generator.start_date_time = date_time
            end
          end
        end
      end
    end
  end
end
