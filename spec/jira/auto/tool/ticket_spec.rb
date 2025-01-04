# frozen_string_literal: true

require 'rspec'

module Jira
  module Auto
    class Tool
      class Ticket
        RSpec.describe Ticket do
          let(:jira_ticket) { instance_double(JIRA::Resource::Issue) }
          let(:ticket) { described_class.new(jira_ticket, nil, nil) }

          describe '#sprint=' do
            context 'when condition' do
              it 'succeeds' do
                allow(jira_ticket).to receive_messages(save: nil)

                ticket.sprint = "a sprint"

                expect(jira_ticket).to have_received(:save).with({
                                                                     sprint: "a sprint"
                                                                  })
              end
            end
          end
        end
      end
    end
  end
end
