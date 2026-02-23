module Api
  module V3
    class PalParkAreaController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokePalParkArea.order(:id),
          cache_key: "v3/pal_park_area#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        pal_park_area = find_by_id_or_name!(PokePalParkArea.all, params[:id])
        render_show_flow(record: pal_park_area, cache_key: "v3/pal_park_area#show")
      end

      private

      def summary_fields
        %i[id name url]
      end

      def detail_fields
        %i[id name url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(pal_park_area, includes:, include_map:)
        {
          id: pal_park_area.id,
          name: pal_park_area.name,
          url: canonical_url_for(pal_park_area, :api_v3_pal_park_area_url)
        }
      end

      def detail_payload(pal_park_area, includes:, include_map:)
        {
          id: pal_park_area.id,
          name: pal_park_area.name,
          url: canonical_url_for(pal_park_area, :api_v3_pal_park_area_url)
        }
      end
    end
  end
end
