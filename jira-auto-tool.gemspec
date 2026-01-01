# frozen_string_literal: true

require_relative "lib/jira/auto/tool/version"

Gem::Specification.new do |spec|
  spec.name = "jira-auto-tool"
  spec.version = Jira::Auto::Tool::VERSION
  spec.authors = ["Christophe Broult"]
  spec.email = ["cbroult@yahoo.com"]

  spec.summary = "Automate making adjustments to Jira sprints for multiple teams following some naming conventions."
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/cbroult/jira-auto-tool"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.7"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/cbroult/jira-auto-tool"
  spec.metadata["changelog_uri"] = "https://github.com/cbroult/jira-auto-tool/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true)
      .reject { |f| f.end_with?(".gem") }
      .reject do |f|
        (f == gemspec) ||
          f.start_with?(*%w[bin/console bin/setup test/ pkg/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }.grep_v(/\.bat$/)
  spec.require_paths = ["lib"]

  if Gem.win_platform?
    ext_conf_rb = File.join(File.dirname(__FILE__), "ext/no_wrappers_win.rb")

    win_config = <<~CONFIG
      # frozen_string_literal: true

      # Disable wrappers only on Windows
      puts 'Disabling wrappers for Windows installation'
      RubyGems.configuration.wrappers = false
      exit 0
    CONFIG

    File.write(ext_conf_rb, win_config)

    spec.extensions << ext_conf_rb
  end

  spec.add_dependency "activesupport"
  spec.add_dependency "cgi"
  spec.add_dependency "http_logger"
  spec.add_dependency "irb"
  spec.add_dependency "jira-ruby"
  spec.add_dependency "logging"
  spec.add_dependency "ostruct"
  spec.add_dependency "ratelimit"
  spec.add_dependency "rb-readline"
  spec.add_dependency "rdoc"
  spec.add_dependency "redis"
  spec.add_dependency "reline"
  spec.add_dependency "ruby-limiter"
  spec.add_dependency "syslog"
  spec.add_dependency "terminal-table"

  if Gem.win_platform?
    spec.add_dependency "fiddle", "1.1.0"
    spec.add_dependency "win32ole"
  end

  spec.metadata["rubygems_mfa_required"] = "true"
end
