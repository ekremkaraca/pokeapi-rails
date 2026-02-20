module Api
  module V3
    class EvolutionChainController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        scope = PokeEvolutionChain
          .joins("LEFT JOIN pokemon_species ON pokemon_species.evolution_chain_id = evolution_chain.id")
          .select("evolution_chain.*")
          .distinct
          .order(:id)

        render_index_flow(
          scope: scope,
          cache_key: "v3/evolution-chain#index",
          sort_allowed: %i[id],
          sort_default: "id",
          q_column: "pokemon_species.name"
        )
      end

      def show
        evolution_chain = PokeEvolutionChain.find(require_numeric_id!(params[:id]))
        render_show_flow(record: evolution_chain, cache_key: "v3/evolution-chain#show")
      end

      private

      def summary_fields
        %i[id url pokemon_species]
      end

      def detail_fields
        %i[id baby_trigger_item_id url pokemon_species]
      end

      def summary_includes
        %i[pokemon_species]
      end

      def detail_includes
        %i[pokemon_species]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(
          records: records,
          includes: includes,
          include_key: :pokemon_species,
          loader: :pokemon_species_by_evolution_chain_id
        )
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(
          record: record,
          includes: includes,
          include_key: :pokemon_species,
          loader: :pokemon_species_by_evolution_chain_id
        )
      end

      def summary_payload(evolution_chain, includes:, include_map:)
        payload = {
          id: evolution_chain.id,
          url: canonical_url_for(evolution_chain, :api_v3_evolution_chain_url)
        }
        payload[:pokemon_species] = include_map.fetch(evolution_chain.id, []) if includes.include?(:pokemon_species)
        payload
      end

      def detail_payload(evolution_chain, includes:, include_map:)
        payload = {
          id: evolution_chain.id,
          baby_trigger_item_id: evolution_chain.baby_trigger_item_id,
          url: canonical_url_for(evolution_chain, :api_v3_evolution_chain_url)
        }
        payload[:pokemon_species] = include_map.fetch(evolution_chain.id, []) if includes.include?(:pokemon_species)
        payload
      end
    end
  end
end
