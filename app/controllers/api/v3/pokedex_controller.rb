module Api
  module V3
    class PokedexController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokePokedex.order(:id),
          cache_key: "v3/pokedex#index",
          sort_allowed: %i[id name is_main_series region_id],
          sort_default: "id"
        )
      end

      def show
        pokedex = PokePokedex.find(require_numeric_id!(params[:id]))
        render_show_flow(record: pokedex, cache_key: "v3/pokedex#show")
      end

      private

      def summary_fields
        %i[id name is_main_series region_id url]
      end

      def detail_fields
        %i[id name is_main_series region_id url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(pokedex, includes:, include_map:)
        {
          id: pokedex.id,
          name: pokedex.name,
          is_main_series: pokedex.is_main_series,
          region_id: pokedex.region_id,
          url: canonical_url_for(pokedex, :api_v3_pokedex_url)
        }
      end

      def detail_payload(pokedex, includes:, include_map:)
        {
          id: pokedex.id,
          name: pokedex.name,
          is_main_series: pokedex.is_main_series,
          region_id: pokedex.region_id,
          url: canonical_url_for(pokedex, :api_v3_pokedex_url)
        }
      end
    end
  end
end
