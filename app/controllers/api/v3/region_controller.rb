module Api
  module V3
    class RegionController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeRegion.order(:id),
          cache_key: "v3/region#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        region = PokeRegion.find(require_numeric_id!(params[:id]))
        render_show_flow(record: region, cache_key: "v3/region#show")
      end

      private

      def summary_fields
        %i[id name url generations]
      end

      def detail_fields
        %i[id name url generations]
      end

      def summary_includes
        %i[generations]
      end

      def detail_includes
        %i[generations]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :generations, loader: :generations_by_region_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :generations, loader: :generations_by_region_id)
      end

      def summary_payload(region, includes:, include_map:)
        payload = {
          id: region.id,
          name: region.name,
          url: canonical_url_for(region, :api_v3_region_url)
        }
        payload[:generations] = include_map.fetch(region.id, []) if includes.include?(:generations)
        payload
      end

      def detail_payload(region, includes:, include_map:)
        payload = {
          id: region.id,
          name: region.name,
          url: canonical_url_for(region, :api_v3_region_url)
        }
        payload[:generations] = include_map.fetch(region.id, []) if includes.include?(:generations)
        payload
      end
    end
  end
end
