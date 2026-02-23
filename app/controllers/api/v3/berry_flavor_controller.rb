module Api
  module V3
    class BerryFlavorController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeBerryFlavor.order(:id),
          cache_key: "v3/berry_flavor#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        flavor = find_by_id_or_name!(PokeBerryFlavor.all, params[:id])
        render_show_flow(record: flavor, cache_key: "v3/berry_flavor#show")
      end

      private

      def summary_fields
        %i[id name url contest_type]
      end

      def detail_fields
        %i[id name contest_type_id url contest_type]
      end

      def summary_includes
        %i[contest_type]
      end

      def detail_includes
        %i[contest_type]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(
          records: records,
          includes: includes,
          include_key: :contest_type,
          loader: :contest_type_by_berry_flavor_id
        )
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(
          record: record,
          includes: includes,
          include_key: :contest_type,
          loader: :contest_type_by_berry_flavor_id
        )
      end

      def summary_payload(flavor, includes:, include_map:)
        payload = {
          id: flavor.id,
          name: flavor.name,
          url: canonical_url_for(flavor, :api_v3_berry_flavor_url)
        }
        payload[:contest_type] = include_map[flavor.id] if includes.include?(:contest_type)
        payload
      end

      def detail_payload(flavor, includes:, include_map:)
        payload = {
          id: flavor.id,
          name: flavor.name,
          contest_type_id: flavor.contest_type_id,
          url: canonical_url_for(flavor, :api_v3_berry_flavor_url)
        }
        payload[:contest_type] = include_map[flavor.id] if includes.include?(:contest_type)
        payload
      end
    end
  end
end
