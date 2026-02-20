module Api
  module V3
    class ItemCategoryController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeItemCategory.order(:id),
          cache_key: "v3/item_category#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        category = PokeItemCategory.find(require_numeric_id!(params[:id]))
        render_show_flow(record: category, cache_key: "v3/item_category#show")
      end

      private

      def summary_fields
        %i[id name pocket_id url pocket]
      end

      def detail_fields
        %i[id name pocket_id url pocket]
      end

      def summary_includes
        %i[pocket]
      end

      def detail_includes
        %i[pocket]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :pocket, loader: :pocket_by_item_category_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :pocket, loader: :pocket_by_item_category_id)
      end

      def summary_payload(category, includes:, include_map:)
        payload = {
          id: category.id,
          name: category.name,
          pocket_id: category.pocket_id,
          url: canonical_url_for(category, :api_v3_item_category_url)
        }
        payload[:pocket] = include_map[category.id] if includes.include?(:pocket)
        payload
      end

      def detail_payload(category, includes:, include_map:)
        payload = {
          id: category.id,
          name: category.name,
          pocket_id: category.pocket_id,
          url: canonical_url_for(category, :api_v3_item_category_url)
        }
        payload[:pocket] = include_map[category.id] if includes.include?(:pocket)
        payload
      end
    end
  end
end
