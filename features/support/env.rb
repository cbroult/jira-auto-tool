# frozen_string_literal: true

module JiraSprintToolWorld
  def remove_existing_sprints(board)
    board.sprints.each(&:delete)
  end
end

World(JiraSprintToolWorld)
