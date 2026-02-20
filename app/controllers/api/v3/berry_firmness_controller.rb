module Api
  module V3
    class BerryFirmnessController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeBerryFirmness.order(:id),
          cache_key: "v3/berry_firmness#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        firmness = PokeBerryFirmness.find(require_numeric_id!(params[:id]))
        render_show_flow(record: firmness, cache_key: "v3/berry_firmness#show")
      end

      private

      def summary_fields
        %i[id name url berries]
      end

      def detail_fields
        %i[id name url berries]
      end

      def summary_includes
        %i[berries]
      end

      def detail_includes
        %i[berries]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(
          records: records,
          includes: includes,
          include_key: :berries,
          loader: :berries_by_firmness_id
        )
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(
          record: record,
          includes: includes,
          include_key: :berries,
          loader: :berries_by_firmness_id
        )
      end

      def summary_payload(firmness, includes:, include_map:)
        payload = {
          id: firmness.id,
          name: firmness.name,
          url: canonical_url_for(firmness, :api_v3_berry_firmness_url)
        }
        payload[:berries] = include_map[firmness.id] if includes.include?(:berries)
        payload
      end

      def detail_payload(firmness, includes:, include_map:)
        payload = {
          id: firmness.id,
          name: firmness.name,
          url: canonical_url_for(firmness, :api_v3_berry_firmness_url)
        }
        payload[:berries] = include_map[firmness.id] if includes.include?(:berries)
        payload
      end
    end
  end
end
