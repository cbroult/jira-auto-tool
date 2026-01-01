# frozen_string_literal: true

source "https://rubygems.org"

ruby File.read(".ruby-version").strip

# Specify your gem's dependencies in jira-auto-tool.gemspec
gemspec

group :development do
  gem "aruba"
  gem "cucumber" # , git: "https://github.com/cucumber/cucumber-ruby.git"
  gem "gem-release"
  gem "mermaid"
  gem "rake"
  gem "rspec"
  gem "rubocop"
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "simplecov", require: false
  gem "wdm", ">= 0.1.0", platform: :windows
  gem "win32ole", platform: :windows

  gem "guard"
  gem "guard-bundler"
  gem "guard-cucumber"
  gem "guard-rspec"
  gem "guard-rubocop"
end
