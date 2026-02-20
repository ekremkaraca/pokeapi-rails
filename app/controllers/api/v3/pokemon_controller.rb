module Api
  module V3
    class PokemonController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: Pokemon.order(:id),
          cache_key: "v3/pokemon#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        pokemon = Pokemon.find(require_numeric_id!(params[:id]))
        render_show_flow(record: pokemon, cache_key: "v3/pokemon#show")
      end

      private

      def summary_fields
        %i[id name url abilities]
      end

      def detail_fields
        %i[id name url abilities]
      end

      def summary_includes
        %i[abilities]
      end

      def detail_includes
        %i[abilities]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :abilities, loader: :abilities_by_pokemon_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :abilities, loader: :abilities_by_pokemon_id)
      end

      def summary_payload(pokemon, includes:, include_map:)
        payload = {
          id: pokemon.id,
          name: pokemon.name,
          url: canonical_url_for(pokemon, :api_v3_pokemon_url)
        }
        payload[:abilities] = include_map.fetch(pokemon.id, []) if includes.include?(:abilities)
        payload
      end

      def detail_payload(pokemon, includes:, include_map:)
        payload = {
          id: pokemon.id,
          name: pokemon.name,
          url: canonical_url_for(pokemon, :api_v3_pokemon_url)
        }
        payload[:abilities] = include_map.fetch(pokemon.id, []) if includes.include?(:abilities)
        payload
      end
    end
  end
end
