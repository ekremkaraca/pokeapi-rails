module Api
  module V3
    module IncludeLoaders
      module PokemonLoaders
        extend ActiveSupport::Concern

        private

        # pokemon_id => [{ is_hidden, slot, ability: { id, name, url } }, ...]
        def abilities_by_pokemon_id(pokemon_ids)
          ids = pokemon_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonAbility.includes(:ability).where(pokemon_id: ids).order(:pokemon_id, :slot, :ability_id)

          rows.group_by(&:pokemon_id).transform_values do |ability_rows|
            ability_rows.filter_map do |row|
              ability = row.ability
              next unless ability

              {
                is_hidden: row.is_hidden,
                slot: row.slot,
                ability: resource_ref(ability, :api_v3_ability_url)
              }
            end
          end
        end

        # ability_id => [{ is_hidden, slot, pokemon: { id, name, url } }, ...]
        def pokemon_by_ability_id(ability_ids)
          ids = ability_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonAbility.includes(:pokemon).where(ability_id: ids).order(:ability_id, :slot, :pokemon_id)

          rows.group_by(&:ability_id).transform_values do |pokemon_rows|
            pokemon_rows.filter_map do |row|
              pokemon = row.pokemon
              next unless pokemon

              {
                is_hidden: row.is_hidden,
                slot: row.slot,
                pokemon: resource_ref(pokemon, :api_v3_pokemon_url)
              }
            end
          end
        end

        # type_id => [{ slot, pokemon: { id, name, url } }, ...]
        def pokemon_by_type_id(type_ids)
          ids = type_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonType.includes(:pokemon).where(type_id: ids).order(:type_id, :slot, :pokemon_id)

          rows.group_by(&:type_id).transform_values do |pokemon_rows|
            pokemon_rows.filter_map do |row|
              pokemon = row.pokemon
              next unless pokemon

              {
                slot: row.slot,
                pokemon: resource_ref(pokemon, :api_v3_pokemon_url)
              }
            end
          end
        end

        # move_id => [{ pokemon: { id, name, url } }, ...]
        def pokemon_by_move_id(move_ids)
          ids = move_ids.uniq
          return {} if ids.empty?

          # Cap high-cardinality include expansions per move to preserve latency
          # budgets while keeping deterministic output ordering by pokemon id.
          dedup_scope = PokePokemonMove
            .select("DISTINCT pokemon_move.move_id, pokemon_move.pokemon_id")
            .where(move_id: ids)

          ranked_scope = PokePokemonMove
            .from("(#{dedup_scope.to_sql}) dedup")
            .select(<<~SQL.squish)
              dedup.move_id,
              dedup.pokemon_id,
              ROW_NUMBER() OVER (
                PARTITION BY dedup.move_id
                ORDER BY dedup.pokemon_id ASC
              ) AS rn
            SQL

          rows = PokePokemonMove
            .from("(#{ranked_scope.to_sql}) ranked")
            .joins("INNER JOIN pokemon ON pokemon.id = ranked.pokemon_id")
            .where("ranked.rn <= ?", MAX_INCLUDED_POKEMON_PER_MOVE)
            .order(Arel.sql("ranked.move_id ASC, pokemon.id ASC"))
            .pluck("ranked.move_id", "pokemon.id", "pokemon.name")

          rows.each_with_object({}) do |(move_id, pokemon_id, pokemon_name), acc|
            move_id = move_id.to_i
            pokemon_id = pokemon_id.to_i
            acc[move_id] ||= []
            acc[move_id] << {
              pokemon: {
                id: pokemon_id,
                name: pokemon_name,
                url: canonical_url_for_id(pokemon_id, :api_v3_pokemon_url)
              }
            }
          end
        end
      end
    end
  end
end
