# frozen_string_literal: true

require "jira/auto/tool/board/unavailable_board"

module Jira
  module Auto
    class Tool
      class Board
        class UnavailableBoard < Board
          RSpec.describe UnavailableBoard do
            let(:tool) { instance_double(Tool) }
            let(:board) { described_class.new(tool, 4) }

            it { expect(board.id).to eq(4) }
            it { expect(board.name).to eq("N/A") }
            it { expect(board.url).to eq("N/A") }

            describe "#<=>" do
              def new_board(id)
                described_class.new(tool, id)
              end

              let(:board_with_same_id) { new_board(4) }

              it { expect(board <=> board_with_same_id).to eq(0) }
              it { expect(new_board(1) <=> board).to eq(-1) }
              it { expect(new_board(5) <=> board).to eq(1) }
            end
          end
        end
      end
    end
  end
end
