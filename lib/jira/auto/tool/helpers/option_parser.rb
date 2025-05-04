# frozen_string_literal: true

require "optparse"
require "jira/auto/tool"

class OptionParser
  def section_header(section_name)
    header_name = "#{section_name}:"

    on <<~EOSH

      #{header_name}
      #{header_name.gsub(/./, "*")}
    EOSH
  end
end
