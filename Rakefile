# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cucumber"
require "cucumber/rake/task"
require "rake"
require "rake/gem_maintenance/install_tasks"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ["--autocorrect"]
end

Cucumber::Rake::Task.new do |t|
  t.profile = "rake"
end

task default: :verify

desc "Run all checks"
task verify: %i[rubocop spec cucumber]
