module Api
  module V3
    class PokemonShapeController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokePokemonShape.order(:id),
          cache_key: "v3/pokemon_shape#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        shape = PokePokemonShape.find(require_numeric_id!(params[:id]))
        render_show_flow(record: shape, cache_key: "v3/pokemon_shape#show")
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

      def summary_payload(shape, includes:, include_map:)
        {
          id: shape.id,
          name: shape.name,
          url: canonical_url_for(shape, :api_v3_pokemon_shape_url)
        }
      end

      def detail_payload(shape, includes:, include_map:)
        {
          id: shape.id,
          name: shape.name,
          url: canonical_url_for(shape, :api_v3_pokemon_shape_url)
        }
      end
    end
  end
end
