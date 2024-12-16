# frozen_string_literal: true

require "logging"

class Object
  def log
    @log ||= Logging.logger[self]
  end
end

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger.root.level = :info
