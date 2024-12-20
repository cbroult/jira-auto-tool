# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in jira-auto-tool.gemspec
gemspec

group :development do
  gem "rake", "~> 13.0"

  gem "rspec", "~> 3.0"

  gem "rubocop", "~> 1.21"

  gem "aruba"
  gem "cucumber", git: "https://github.com/cucumber/cucumber-ruby.git"
  gem "fiddle", platform: :mswin
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "win32ole", platform: :mswin

  gem "guard"
  gem "guard-bundler"
  gem "guard-cucumber"
  gem "guard-rspec"
  gem "guard-rubocop"
end
