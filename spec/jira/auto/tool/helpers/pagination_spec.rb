# frozen_string_literal: true

require "jira/auto/tool/helpers/pagination"

class PaginatedObjectFetcher
  def fetch_objects(pagination_options) end
end

RSpec.describe Jira::Auto::Tool::Helpers::Pagination do
  describe ".fetch_all_object_pages" do
    let(:object) { PaginatedObjectFetcher.new }

    shared_examples "paginated request" do |parameter_naming_convention|
      describe "#build_pagination_options" do
        it "respects the parameter naming convention" do
          expect(described_class.build_pagination_options(parameter_naming_convention, 50, 0))
            .to eq(expected_build_pagination_options)
        end
      end

      let(:object_pages_to_return) do
        [
          %w[object_1 object_2],
          %w[object_3 object_4],
          %w[object_5],
          %w[]
        ]
      end

      it "deals with JIRA::Resource pagination" do
        expected_multi_page_options.zip(object_pages_to_return).each do
        |expected_pagination_options, object_page_to_return|

          allow(object).to receive(:fetch_objects).with(expected_pagination_options).and_return(object_page_to_return)
        end

        expect(described_class.fetch_all_object_pages(parameter_naming_convention) do |pagination_options|
          object.fetch_objects(pagination_options)
        end)
          .to eq(%w[object_1 object_2 object_3 object_4 object_5])
      end
    end

    context "when :snake_case parameter naming convention used" do
      let(:page_keyset) { %i[start_at max_results] }
      let(:expected_build_pagination_options) { { max_results: 50, start_at: 0 } }

      let(:expected_multi_page_options) do
        [{ max_results: 50, start_at: 0 },
         { max_results: 50, start_at: 50 },
         { max_results: 50, start_at: 100 },
         { max_results: 50, start_at: 150 }]
      end

      it_behaves_like "paginated request", :snake_case
    end

    context "when :camelCase parameter naming convention used" do
      let(:page_keyset) { %i[startAt maxResults] }
      let(:expected_build_pagination_options) { { maxResults: 50, startAt: 0 } }

      let(:expected_multi_page_options) do
        [{ maxResults: 50, startAt: 0 },
         { maxResults: 50, startAt: 50 },
         { maxResults: 50, startAt: 100 },
         { maxResults: 50, startAt: 150 }]
      end

      it_behaves_like "paginated request", :camelCase
    end
  end
end
