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

# Step 2: Configure HttpLogger to use the Logging logger
HttpLogger.logger = logging_logger
HttpLogger.colorize = false # Disable colorize, as it's handled by Logging
HttpLogger.log_headers = true # Log request and response headers
HttpLogger.log_request_body = true # Log request body
HttpLogger.log_response_body = true # Log response body
