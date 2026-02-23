module Api
  module V3
    class LocationAreaController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeLocationArea.order(:id),
          cache_key: "v3/location_area#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        area = find_by_id_or_name!(PokeLocationArea.all, params[:id])
        render_show_flow(record: area, cache_key: "v3/location_area#show")
      end

      private

      def summary_fields
        %i[id name game_index location_id url location]
      end

      def detail_fields
        %i[id name game_index location_id url location]
      end

      def summary_includes
        %i[location]
      end

      def detail_includes
        %i[location]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(
          records: records,
          includes: includes,
          include_key: :location,
          loader: :location_by_location_area_id
        )
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(
          record: record,
          includes: includes,
          include_key: :location,
          loader: :location_by_location_area_id
        )
      end

      def summary_payload(area, includes:, include_map:)
        payload = {
          id: area.id,
          name: area.name,
          game_index: area.game_index,
          location_id: area.location_id,
          url: canonical_url_for(area, :api_v3_location_area_url)
        }
        payload[:location] = include_map[area.id] if includes.include?(:location)
        payload
      end

      def detail_payload(area, includes:, include_map:)
        payload = {
          id: area.id,
          name: area.name,
          game_index: area.game_index,
          location_id: area.location_id,
          url: canonical_url_for(area, :api_v3_location_area_url)
        }
        payload[:location] = include_map[area.id] if includes.include?(:location)
        payload
      end
    end
  end
end
