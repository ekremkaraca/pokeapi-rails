module Api
  module V3
    class LocationController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeLocation.order(:id),
          cache_key: "v3/location#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        location = find_by_id_or_name!(PokeLocation.all, params[:id])
        render_show_flow(record: location, cache_key: "v3/location#show")
      end

      private

      def summary_fields
        %i[id name region_id url region]
      end

      def detail_fields
        %i[id name region_id url region]
      end

      def summary_includes
        %i[region]
      end

      def detail_includes
        %i[region]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :region, loader: :region_by_location_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :region, loader: :region_by_location_id)
      end

      def summary_payload(location, includes:, include_map:)
        payload = {
          id: location.id,
          name: location.name,
          region_id: location.region_id,
          url: canonical_url_for(location, :api_v3_location_url)
        }
        payload[:region] = include_map[location.id] if includes.include?(:region)
        payload
      end

      def detail_payload(location, includes:, include_map:)
        payload = {
          id: location.id,
          name: location.name,
          region_id: location.region_id,
          url: canonical_url_for(location, :api_v3_location_url)
        }
        payload[:region] = include_map[location.id] if includes.include?(:region)
        payload
      end
    end
  end
end
