module Api
  module V3
    class PokemonSpeciesController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokePokemonSpecies.order(:id),
          cache_key: "v3/pokemon-species#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        species = PokePokemonSpecies.find(require_numeric_id!(params[:id]))
        render_show_flow(record: species, cache_key: "v3/pokemon-species#show")
      end

      private

      def summary_fields
        %i[id name url generation]
      end

      def detail_fields
        %i[id name base_happiness capture_rate generation_id evolution_chain_id is_baby is_legendary is_mythical url generation]
      end

      def summary_includes
        %i[generation]
      end

      def detail_includes
        %i[generation]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :generation, loader: :generation_by_species_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :generation, loader: :generation_by_species_id)
      end

      def summary_payload(species, includes:, include_map:)
        payload = {
          id: species.id,
          name: species.name,
          url: canonical_url_for(species, :api_v3_pokemon_species_url)
        }
        payload[:generation] = include_map[species.id] if includes.include?(:generation)
        payload
      end

      def detail_payload(species, includes:, include_map:)
        payload = {
          id: species.id,
          name: species.name,
          base_happiness: species.base_happiness,
          capture_rate: species.capture_rate,
          generation_id: species.generation_id,
          evolution_chain_id: species.evolution_chain_id,
          is_baby: species.is_baby,
          is_legendary: species.is_legendary,
          is_mythical: species.is_mythical,
          url: canonical_url_for(species, :api_v3_pokemon_species_url)
        }
        payload[:generation] = include_map[species.id] if includes.include?(:generation)
        payload
      end
    end
  end
end
