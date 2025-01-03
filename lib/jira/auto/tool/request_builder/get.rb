# frozen_string_literal: true

require "jira/auto/tool/request_builder"

module Jira
  module Auto
    class Tool
      class RequestBuilder
        class Get < RequestBuilder
          def request_payload
            nil
          end

          def http_verb
            :get
          end

          def expected_response
            200
          end

          def request_headers
            nil
          end
        end
      end
    end
  end
end
