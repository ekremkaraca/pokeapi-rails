module Api
  module V3
    class ItemFlingEffectController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeItemFlingEffect.order(:id),
          cache_key: "v3/item_fling_effect#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        fling_effect = PokeItemFlingEffect.find(require_numeric_id!(params[:id]))
        render_show_flow(record: fling_effect, cache_key: "v3/item_fling_effect#show")
      end

      private

      def summary_fields
        %i[id name url items]
      end

      def detail_fields
        %i[id name url items]
      end

      def summary_includes
        %i[items]
      end

      def detail_includes
        %i[items]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :items, loader: :items_by_fling_effect_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :items, loader: :items_by_fling_effect_id)
      end

      def summary_payload(fling_effect, includes:, include_map:)
        payload = {
          id: fling_effect.id,
          name: fling_effect.name,
          url: canonical_url_for(fling_effect, :api_v3_item_fling_effect_url)
        }
        payload[:items] = include_map.fetch(fling_effect.id, []) if includes.include?(:items)
        payload
      end

      def detail_payload(fling_effect, includes:, include_map:)
        payload = {
          id: fling_effect.id,
          name: fling_effect.name,
          url: canonical_url_for(fling_effect, :api_v3_item_fling_effect_url)
        }
        payload[:items] = include_map.fetch(fling_effect.id, []) if includes.include?(:items)
        payload
      end
    end
  end
end
