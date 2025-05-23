# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

guard :bundler do
  require "guard/bundler"
  require "guard/bundler/verify"
  helper = Guard::Bundler::Verify.new

  files = ["Gemfile"]
  files += Dir["*.gemspec"] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end

require "guard/rspec/dsl"

def guard_rspec
  guard :rspec, cmd: "bundle exec rspec --format progress" do
    dsl = Guard::RSpec::Dsl.new(self)

    rspec = dsl.rspec
    watch(rspec.spec_helper) { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)
    watch(%r{^(bin|lib)/.+$}) { rspec.spec_dir }

    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)
  end
end

def guard_rubocop
  guard :rubocop, cli: ["--format", "clang", "--autocorrect"] do
    watch(/.+\.rb$/)
    watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
  end
end

def cucumber_options
  {
    # Below are examples overriding defaults

    # cmd: 'bin/cucumber',
    cmd_additional_args: "--profile guard",

    # all_after_pass: false,
    # all_on_start: false,
    # keep_failed: false,
    # feature_sets: ['features/frontend', 'features/experimental'],

    # run_all: { cmd_additional_args: '--profile guard_all' },
    # focus_on: { 'wip' }, # @wip
    notification: false
  }
end

def cucumber_start_by_rerunning_failures_if_any
  rerun_file = "rerun_failures.txt"

  # If rerun file exists, rerun failed features first
  if File.exist?(rerun_file) && !File.empty?(rerun_file)
    # Return the failures to rerun them
    ["@rerun", File.read(rerun_file).strip]
  else
    # Run full test suite if no recorded failures
    :all
  end
end

def guard_cucumber
  guard "cucumber", cucumber_options do
    watch(%r{^features/.+\.feature$}) { |_m| cucumber_start_by_rerunning_failures_if_any }

    watch(%r{^features/support/.+$}) { "features" }
    watch(%r{^(bin|lib)/.+$}) { "features" }
    watch("cucumber.yml")

    watch(%r{^features/step_definitions/(.+)_steps\.rb$}) do |m|
      Dir[File.join("**/#{m[1]}.feature")][0] || "features"
    end
  end
end

group :red_green_refactor, halt_on_fail: true do
  guard_rspec
  guard_rubocop
  guard_cucumber
end
