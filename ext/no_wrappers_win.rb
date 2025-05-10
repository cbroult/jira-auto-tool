# frozen_string_literal: true

# Disable wrappers only on Windows
puts "Disabling wrappers for Windows installation"
RubyGems.configuration.wrappers = false
exit 0
