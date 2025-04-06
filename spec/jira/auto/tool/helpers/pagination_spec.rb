# frozen_string_literal: true

require "jira/auto/tool/helpers/pagination"

class PaginatedObjectFetcher
  def fetch_objects(pagination_options) end
end

RSpec.describe Jira::Auto::Tool::Helpers::Pagination do
  describe ".fetch_all_object_pages" do
    let(:object) { PaginatedObjectFetcher.new }

    it "deals with JIRA::Resource pagination" do
      allow(object).to receive(:fetch_objects).with({ maxResults: 50, startAt: 0 }).and_return(%w[object_1 object_2])

      allow(object).to receive(:fetch_objects).with({ maxResults: 50, startAt: 50 }).and_return(%w[object_3 object_4])

      allow(object).to receive(:fetch_objects).with({ maxResults: 50, startAt: 100 }).and_return(%w[object_5])
      allow(object).to receive(:fetch_objects).with({ maxResults: 50, startAt: 150 }).and_return(%w[])

      expect(described_class.fetch_all_object_pages { |pagination_options| object.fetch_objects(pagination_options) })
        .to eq(%w[object_1 object_2 object_3 object_4 object_5])
    end
  end
end
