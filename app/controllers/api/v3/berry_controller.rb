module Api
  module V3
    class BerryController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeBerry.order(:id),
          cache_key: "v3/berry#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        berry = find_by_id_or_name!(PokeBerry.all, params[:id])
        render_show_flow(record: berry, cache_key: "v3/berry#show")
      end

      private

      def summary_fields
        %i[id name url]
      end

      def detail_fields
        %i[id name item_id firmness_id natural_gift_power natural_gift_type_id size max_harvest growth_time soil_dryness smoothness url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(berry, includes:, include_map:)
        {
          id: berry.id,
          name: berry.name,
          url: canonical_url_for(berry, :api_v3_berry_url)
        }
      end

      def detail_payload(berry, includes:, include_map:)
        {
          id: berry.id,
          name: berry.name,
          item_id: berry.item_id,
          firmness_id: berry.berry_firmness_id,
          natural_gift_power: berry.natural_gift_power,
          natural_gift_type_id: berry.natural_gift_type_id,
          size: berry.size,
          max_harvest: berry.max_harvest,
          growth_time: berry.growth_time,
          soil_dryness: berry.soil_dryness,
          smoothness: berry.smoothness,
          url: canonical_url_for(berry, :api_v3_berry_url)
        }
      end
    end
  end
end
