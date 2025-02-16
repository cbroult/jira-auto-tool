# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in jira-auto-tool.gemspec
gemspec

group :development do
  gem "rake"

  gem "rspec"

  gem "rubocop"

  gem "aruba"
  gem "cucumber" # , git: "https://github.com/cucumber/cucumber-ruby.git"
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "simplecov", require: false
  gem "wdm", ">= 0.1.0", platform: :mswin
  gem "win32ole", platform: :mswin

  gem "guard"
  gem "guard-bundler"
  gem "guard-cucumber"
  gem "guard-rspec"
  gem "guard-rubocop"
end
