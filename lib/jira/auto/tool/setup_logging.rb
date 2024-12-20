# frozen_string_literal: true

require "http_logger"
require "logging"

class Object
  def log
    @log ||= Logging.logger[self]
  end
end

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger.root.level = :info

logging_logger = Logging.logger["HTTPLogger"]
logging_logger.level = :info # Log everything at debug level
logging_logger.add_appenders(
  Logging.appenders.stdout, # Log to STDOUT
  Logging.appenders.file("http_requests.log") # Log to a file
)

# Step 2: Configure HttpLogger to use the Logging logger
HttpLogger.logger = logging_logger
HttpLogger.colorize = false # Disable colorize, as it's handled by Logging
HttpLogger.log_headers = true # Log request and response headers
HttpLogger.log_request_body = true # Log request body
HttpLogger.log_response_body = true # Log response body
