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

        # pokemon_id => [{ slot, type: { id, name, url } }, ...]
        def types_by_pokemon_id(pokemon_ids)
          ids = pokemon_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonType.includes(:type).where(pokemon_id: ids).order(:pokemon_id, :slot)

          rows.group_by(&:pokemon_id).transform_values do |type_rows|
            type_rows.filter_map do |row|
              type = row.type
              next unless type

              {
                slot: row.slot,
                type: resource_ref(type, :api_v3_type_url)
              }
            end
          end
        end

        # pokemon_id => [{ base_stat, effort, stat: { id, name, url } }, ...]
        def stats_by_pokemon_id(pokemon_ids)
          ids = pokemon_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonStat.includes(:stat).where(pokemon_id: ids).order(:pokemon_id, :stat_id)

          rows.group_by(&:pokemon_id).transform_values do |stat_rows|
            stat_rows.filter_map do |row|
              stat = row.stat
              next unless stat

              {
                base_stat: row.base_stat,
                effort: row.effort,
                stat: resource_ref(stat, :api_v3_stat_url)
              }
            end
          end
        end

        # pokemon_id => [{ id, name, url }, ...]
        def forms_by_pokemon_id(pokemon_ids)
          ids = pokemon_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonForm.where(pokemon_id: ids).order(:id)

          rows.group_by(&:pokemon_id).transform_values do |form_rows|
            form_rows.filter_map do |row|
              {
                id: row.id,
                name: row.name,
                url: canonical_url_for(row, :api_v3_pokemon_form_url)
              }
            end
          end
        end

        # pokemon_id => [{ item: { id, name, url }, version_details: [{ rarity, version: { id, name, url } }] }, ...]
        def held_items_by_pokemon_id(pokemon_ids)
          ids = pokemon_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonItem.includes(:item, :version).where(pokemon_id: ids).order(:item_id, :version_id)

          rows.group_by(&:pokemon_id).transform_values do |item_rows|
            item_rows.group_by(&:item_id).filter_map do |item_id, entries|
              item = entries.first&.item
              next unless item

              {
                item: resource_ref(item, :api_v3_item_url),
                version_details: entries.filter_map do |row|
                  version = row.version
                  next unless version

                  {
                    rarity: row.rarity,
                    version: resource_ref(version, :api_v3_version_url)
                  }
                end
              }
            end
          end
        end

        # pokemon_id => [{ move: { id, name, url }, version_group_details: [...] }, ...]
        def moves_by_pokemon_id(pokemon_ids)
          ids = pokemon_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonMove
            .includes(:move, :version_group, :move_learn_method)
            .where(pokemon_id: ids)
            .order(:move_id, :version_group_id, :pokemon_move_method_id, :level)

          rows.group_by(&:pokemon_id).transform_values do |move_rows|
            move_rows.group_by(&:move_id).filter_map do |move_id, entries|
              move = entries.first&.move
              next unless move

              {
                move: resource_ref(move, :api_v3_move_url),
                version_group_details: entries.filter_map do |row|
                  version_group = row.version_group
                  move_learn_method = row.move_learn_method
                  next unless version_group && move_learn_method

                  {
                    level_learned_at: row.level,
                    version_group: resource_ref(version_group, :api_v3_version_group_url),
                    move_learn_method: resource_ref(move_learn_method, :api_v3_move_learn_method_url),
                    order: row.sort_order
                  }
                end
              }
            end
          end
        end

        # pokemon_id => [{ game_index, version: { id, name, url } }, ...]
        def game_indices_by_pokemon_id(pokemon_ids)
          ids = pokemon_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonGameIndex.includes(:version).where(pokemon_id: ids).order(:version_id, :game_index)

          rows.group_by(&:pokemon_id).transform_values do |game_index_rows|
            game_index_rows.filter_map do |row|
              version = row.version
              next unless version

              {
                game_index: row.game_index,
                version: resource_ref(version, :api_v3_version_url)
              }
            end
          end
        end

        # pokemon_id => [{ generation: { id, name, url }, abilities: [...] }, ...]
        def past_abilities_by_pokemon_id(pokemon_ids)
          ids = pokemon_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonAbilityPast.includes(:generation, :ability).where(pokemon_id: ids).order(:generation_id, :slot)

          rows.group_by(&:pokemon_id).transform_values do |ability_rows|
            ability_rows.group_by(&:generation_id)
              .sort
              .filter_map do |generation_id, entries|
                generation = entries.first&.generation
                next unless generation

                {
                  generation: resource_ref(generation, :api_v3_generation_url),
                  abilities: entries.map do |row|
                    ability = row.ability

                    {
                      is_hidden: row.is_hidden,
                      slot: row.slot,
                      ability: ability ? resource_ref(ability, :api_v3_ability_url) : nil
                    }
                  end
                }
              end
          end
        end

        # pokemon_id => [{ generation: { id, name, url }, stats: [...] }, ...]
        def past_stats_by_pokemon_id(pokemon_ids)
          ids = pokemon_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonStatPast.includes(:generation, :stat).where(pokemon_id: ids).order(:generation_id, :stat_id)

          rows.group_by(&:pokemon_id).transform_values do |stat_rows|
            stat_rows.group_by(&:generation_id)
              .sort
              .filter_map do |generation_id, entries|
                generation = entries.first&.generation
                next unless generation

                {
                  generation: resource_ref(generation, :api_v3_generation_url),
                  stats: entries.filter_map do |row|
                    stat = row.stat
                    next unless stat

                    {
                      base_stat: row.base_stat,
                      effort: row.effort,
                      stat: resource_ref(stat, :api_v3_stat_url)
                    }
                  end
                }
              end
          end
        end

        # pokemon_id => [{ generation: { id, name, url }, types: [...] }, ...]
        def past_types_by_pokemon_id(pokemon_ids)
          ids = pokemon_ids.uniq
          return {} if ids.empty?

          rows = PokePokemonTypePast.includes(:generation, :type).where(pokemon_id: ids).order(:generation_id, :slot)

          rows.group_by(&:pokemon_id).transform_values do |type_rows|
            type_rows.group_by(&:generation_id)
              .sort
              .filter_map do |generation_id, entries|
                generation = entries.first&.generation
                next unless generation

                {
                  generation: resource_ref(generation, :api_v3_generation_url),
                  types: entries.filter_map do |row|
                    type = row.type
                    next unless type

                    {
                      slot: row.slot,
                      type: resource_ref(type, :api_v3_type_url)
                    }
                  end
                }
              end
          end
        end

        private

        def resource_ref(record, route_helper)
          {
            id: record.id,
            name: record.name,
            url: canonical_url_for(record, route_helper)
          }
        end
      end
    end
  end
end
