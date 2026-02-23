module Api
  module V3
    class ItemPocketController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeItemPocket.order(:id),
          cache_key: "v3/item_pocket#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        pocket = find_by_id_or_name!(PokeItemPocket.all, params[:id])
        render_show_flow(record: pocket, cache_key: "v3/item_pocket#show")
      end

      private

      def summary_fields
        %i[id name url item_categories]
      end

      def detail_fields
        %i[id name url item_categories]
      end

      def summary_includes
        %i[item_categories]
      end

      def detail_includes
        %i[item_categories]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(
          records: records,
          includes: includes,
          include_key: :item_categories,
          loader: :item_categories_by_pocket_id
        )
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(
          record: record,
          includes: includes,
          include_key: :item_categories,
          loader: :item_categories_by_pocket_id
        )
      end

      def summary_payload(pocket, includes:, include_map:)
        payload = {
          id: pocket.id,
          name: pocket.name,
          url: canonical_url_for(pocket, :api_v3_item_pocket_url)
        }
        payload[:item_categories] = include_map.fetch(pocket.id, []) if includes.include?(:item_categories)
        payload
      end

      def detail_payload(pocket, includes:, include_map:)
        payload = {
          id: pocket.id,
          name: pocket.name,
          url: canonical_url_for(pocket, :api_v3_item_pocket_url)
        }
        payload[:item_categories] = include_map.fetch(pocket.id, []) if includes.include?(:item_categories)
        payload
      end
    end
  end
end
