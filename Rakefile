# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cucumber"
require "cucumber/rake/task"
require "rake"

# Load custom tasks
Dir.glob("lib/tasks/**/*.rake").each { |r| load r }

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ["--autocorrect"]
end

Cucumber::Rake::Task.new do |t|
  t.profile = "rake"
end

task default: %i[rubocop spec cucumber]
