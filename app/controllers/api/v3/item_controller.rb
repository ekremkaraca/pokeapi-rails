module Api
  module V3
    class ItemController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeItem.order(:id),
          cache_key: "v3/item#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        item = PokeItem.find(require_numeric_id!(params[:id]))
        render_show_flow(record: item, cache_key: "v3/item#show")
      end

      private

      def summary_fields
        %i[id name cost url category]
      end

      def detail_fields
        %i[id name cost fling_power fling_effect_id category_id url category]
      end

      def summary_includes
        %i[category]
      end

      def detail_includes
        %i[category]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :category, loader: :category_by_item_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :category, loader: :category_by_item_id)
      end

      def summary_payload(item, includes:, include_map:)
        payload = {
          id: item.id,
          name: item.name,
          cost: item.cost,
          url: canonical_url_for(item, :api_v3_item_url)
        }
        payload[:category] = include_map[item.id] if includes.include?(:category)
        payload
      end

      def detail_payload(item, includes:, include_map:)
        payload = {
          id: item.id,
          name: item.name,
          cost: item.cost,
          fling_power: item.fling_power,
          fling_effect_id: item.fling_effect_id,
          category_id: item.category_id,
          url: canonical_url_for(item, :api_v3_item_url)
        }
        payload[:category] = include_map[item.id] if includes.include?(:category)
        payload
      end
    end
  end
end
