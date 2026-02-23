module Api
  module V3
    class ItemAttributeController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeItemAttribute.order(:id),
          cache_key: "v3/item_attribute#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        attribute = find_by_id_or_name!(PokeItemAttribute.all, params[:id])
        render_show_flow(record: attribute, cache_key: "v3/item_attribute#show")
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
        include_map_for_collection(records: records, includes: includes, include_key: :items, loader: :items_by_item_attribute_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :items, loader: :items_by_item_attribute_id)
      end

      def summary_payload(attribute, includes:, include_map:)
        payload = {
          id: attribute.id,
          name: attribute.name,
          url: canonical_url_for(attribute, :api_v3_item_attribute_url)
        }
        payload[:items] = include_map.fetch(attribute.id, []) if includes.include?(:items)
        payload
      end

      def detail_payload(attribute, includes:, include_map:)
        payload = {
          id: attribute.id,
          name: attribute.name,
          url: canonical_url_for(attribute, :api_v3_item_attribute_url)
        }
        payload[:items] = include_map.fetch(attribute.id, []) if includes.include?(:items)
        payload
      end
    end
  end
end
