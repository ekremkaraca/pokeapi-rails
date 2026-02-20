module Api
  module V3
    class PokemonHabitatController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokePokemonHabitat.order(:id),
          cache_key: "v3/pokemon_habitat#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        habitat = PokePokemonHabitat.find(require_numeric_id!(params[:id]))
        render_show_flow(record: habitat, cache_key: "v3/pokemon_habitat#show")
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

      def summary_payload(habitat, includes:, include_map:)
        {
          id: habitat.id,
          name: habitat.name,
          url: canonical_url_for(habitat, :api_v3_pokemon_habitat_url)
        }
      end

      def detail_payload(habitat, includes:, include_map:)
        {
          id: habitat.id,
          name: habitat.name,
          url: canonical_url_for(habitat, :api_v3_pokemon_habitat_url)
        }
      end
    end
  end
end
