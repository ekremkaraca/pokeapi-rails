module Api
  module V3
    class PokeathlonStatController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokePokeathlonStat.order(:id),
          cache_key: "v3/pokeathlon_stat#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        pokeathlon_stat = find_by_id_or_name!(PokePokeathlonStat.all, params[:id])
        render_show_flow(record: pokeathlon_stat, cache_key: "v3/pokeathlon_stat#show")
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

      def summary_payload(pokeathlon_stat, includes:, include_map:)
        {
          id: pokeathlon_stat.id,
          name: pokeathlon_stat.name,
          url: canonical_url_for(pokeathlon_stat, :api_v3_pokeathlon_stat_url)
        }
      end

      def detail_payload(pokeathlon_stat, includes:, include_map:)
        {
          id: pokeathlon_stat.id,
          name: pokeathlon_stat.name,
          url: canonical_url_for(pokeathlon_stat, :api_v3_pokeathlon_stat_url)
        }
      end
    end
  end
end
