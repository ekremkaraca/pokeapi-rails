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
        pokemon = find_by_id_or_name!(show_scope, params[:id])
        render_show_flow(record: pokemon, cache_key: "v3/pokemon#show")
      end

      private

      def show_scope
        Pokemon.select(:id, :name, :base_experience, :height, :is_default, :weight, :sort_order, :species_id, :updated_at)
      end

      def summary_fields
        %i[id name url abilities]
      end

      def detail_fields
        %i[
          id name url base_experience height is_default weight order
          abilities types stats forms held_items moves game_indices
          past_abilities past_stats past_types species
          location_area_encounters
        ]
      end

      def summary_includes
        %i[abilities]
      end

      def detail_includes
        %i[abilities types stats forms held_items moves game_indices
           past_abilities past_stats past_types species]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :abilities, loader: :abilities_by_pokemon_id)
      end

      def detail_include_map(record:, includes:)
        result = {}

        if includes.include?(:abilities)
          result[:abilities] = include_map_for_resource(
            record: record,
            includes: includes,
            include_key: :abilities,
            loader: :abilities_by_pokemon_id
          ).fetch(record.id, [])
        end

        if includes.include?(:types)
          result[:types] = include_map_for_resource(
            record: record,
            includes: includes,
            include_key: :types,
            loader: :types_by_pokemon_id
          ).fetch(record.id, [])
        end

        if includes.include?(:stats)
          result[:stats] = include_map_for_resource(
            record: record,
            includes: includes,
            include_key: :stats,
            loader: :stats_by_pokemon_id
          ).fetch(record.id, [])
        end

        if includes.include?(:forms)
          result[:forms] = include_map_for_resource(
            record: record,
            includes: includes,
            include_key: :forms,
            loader: :forms_by_pokemon_id
          ).fetch(record.id, [])
        end

        if includes.include?(:held_items)
          result[:held_items] = include_map_for_resource(
            record: record,
            includes: includes,
            include_key: :held_items,
            loader: :held_items_by_pokemon_id
          ).fetch(record.id, [])
        end

        if includes.include?(:moves)
          result[:moves] = include_map_for_resource(
            record: record,
            includes: includes,
            include_key: :moves,
            loader: :moves_by_pokemon_id
          ).fetch(record.id, [])
        end

        if includes.include?(:game_indices)
          result[:game_indices] = include_map_for_resource(
            record: record,
            includes: includes,
            include_key: :game_indices,
            loader: :game_indices_by_pokemon_id
          ).fetch(record.id, [])
        end

        if includes.include?(:past_abilities)
          result[:past_abilities] = include_map_for_resource(
            record: record,
            includes: includes,
            include_key: :past_abilities,
            loader: :past_abilities_by_pokemon_id
          ).fetch(record.id, [])
        end

        if includes.include?(:past_stats)
          result[:past_stats] = include_map_for_resource(
            record: record,
            includes: includes,
            include_key: :past_stats,
            loader: :past_stats_by_pokemon_id
          ).fetch(record.id, [])
        end

        if includes.include?(:past_types)
          result[:past_types] = include_map_for_resource(
            record: record,
            includes: includes,
            include_key: :past_types,
            loader: :past_types_by_pokemon_id
          ).fetch(record.id, [])
        end

        if includes.include?(:species)
          result[:species] = load_species_for(record)
        end

        result
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
          url: canonical_url_for(pokemon, :api_v3_pokemon_url),
          base_experience: pokemon.base_experience,
          height: pokemon.height,
          is_default: pokemon.is_default,
          weight: pokemon.weight,
          order: pokemon.sort_order,
          location_area_encounters: "/api/v3/pokemon/#{pokemon.id}/encounters"
        }

        payload[:abilities] = include_map[:abilities] if includes.include?(:abilities)
        payload[:types] = include_map[:types] if includes.include?(:types)
        payload[:stats] = include_map[:stats] if includes.include?(:stats)
        payload[:forms] = include_map[:forms] if includes.include?(:forms)
        payload[:held_items] = include_map[:held_items] if includes.include?(:held_items)
        payload[:moves] = include_map[:moves] if includes.include?(:moves)
        payload[:game_indices] = include_map[:game_indices] if includes.include?(:game_indices)
        payload[:past_abilities] = include_map[:past_abilities] if includes.include?(:past_abilities)
        payload[:past_stats] = include_map[:past_stats] if includes.include?(:past_stats)
        payload[:past_types] = include_map[:past_types] if includes.include?(:past_types)
        payload[:species] = include_map[:species] if includes.include?(:species)

        payload
      end

      def load_species_for(pokemon)
        species = pokemon.species
        return nil unless species

        {
          id: species.id,
          name: species.name,
          url: canonical_url_for(species, :api_v3_pokemon_species_url)
        }
      end
    end
  end
end
