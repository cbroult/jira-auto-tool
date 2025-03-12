# frozen_string_literal: true

require "http_logger"
require "logging"

class Object
  def log
    @log ||= Logging.logger[self]
  end
end

log_dir = File.join("log")
FileUtils.makedirs(log_dir)

Logging.logger.root.add_appenders(
  Logging.appenders.stdout(level: :info),
  Logging.appenders.file(File.join(log_dir, "#{File.basename($PROGRAM_NAME)}.log"), level: :info)
)

Logging.logger.root.level = :info

logging_logger = Logging.logger["HTTPLogger"]
logging_logger.level = :debug # info
logging_logger.add_appenders(
  Logging.appenders.stdout(level: :warn),
  Logging.appenders.file(File.join(log_dir, "http_requests.log"), level: :debug)
)

HttpLogger.configure do |config|
  config.logger = logging_logger
  config.colorize = false
  config.log_headers = true
  config.log_request_body = true
  config.log_response_body = true
end
