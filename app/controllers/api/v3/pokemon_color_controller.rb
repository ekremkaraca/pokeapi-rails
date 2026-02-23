module Api
  module V3
    class PokemonColorController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokePokemonColor.order(:id),
          cache_key: "v3/pokemon_color#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        color = find_by_id_or_name!(PokePokemonColor.all, params[:id])
        render_show_flow(record: color, cache_key: "v3/pokemon_color#show")
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

      def summary_payload(color, includes:, include_map:)
        {
          id: color.id,
          name: color.name,
          url: canonical_url_for(color, :api_v3_pokemon_color_url)
        }
      end

      def detail_payload(color, includes:, include_map:)
        {
          id: color.id,
          name: color.name,
          url: canonical_url_for(color, :api_v3_pokemon_color_url)
        }
      end
    end
  end
end
