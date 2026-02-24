module Api
  module V2
    class PokemonController < BaseController
      include NameSearchableResource

      MODEL_CLASS = Pokemon
      RESOURCE_URL_HELPER = :api_v2_pokemon_url

      def show
        pokemon = find_by_id_or_name!(detail_scope, params[:id])
        return unless stale_resource?(record: pokemon, cache_key: "#{model_class.name.underscore}/show")

        payload = cached_json_payload("api/v2/pokemon/show/#{pokemon.cache_key_with_version}") do
          detail_payload(pokemon)
        end

        render json: payload
      end

      private

      def detail_scope
        Pokemon.preload(
          :species,
          :pokemon_forms,
          :pokemon_abilities,
          :pokemon_ability_pasts,
          :pokemon_game_indices,
          :pokemon_items,
          :pokemon_moves,
          :pokemon_stat_pasts,
          :pokemon_type_pasts,
          :pokemon_stats,
          :pokemon_types
        )
      end

      def detail_payload(pokemon)
        species = pokemon.species

        {
          abilities: abilities_payload(pokemon),
          base_experience: pokemon.base_experience,
          cries: cries_payload(pokemon.id),
          forms: forms_payload(pokemon),
          game_indices: game_indices_payload(pokemon),
          height: pokemon.height,
          held_items: held_items_payload(pokemon),
          id: pokemon.id,
          is_default: pokemon.is_default,
          location_area_encounters: "/api/v2/pokemon/#{pokemon.id}/encounters",
          moves: moves_payload(pokemon),
          name: pokemon.name,
          order: pokemon.sort_order,
          past_abilities: past_abilities_payload(pokemon),
          past_stats: past_stats_payload(pokemon),
          past_types: past_types_payload(pokemon),
          species: species_payload(species),
          sprites: sprites_payload(pokemon.id, species),
          stats: stats_payload(pokemon),
          types: types_payload(pokemon),
          weight: pokemon.weight
        }
      end

      def abilities_payload(pokemon)
        rows = pokemon.pokemon_abilities.sort_by { |row| [ row.slot.to_i, row.ability_id.to_i ] }
        abilities_by_id = records_by_id(Ability, rows.map(&:ability_id))

        rows.filter_map do |row|
          ability = abilities_by_id[row.ability_id]
          next unless ability

          {
            is_hidden: row.is_hidden,
            slot: row.slot,
            ability: resource_payload(ability, :api_v2_ability_url)
          }
        end
      end

      def past_abilities_payload(pokemon)
        rows = pokemon.pokemon_ability_pasts.sort_by { |row| [ row.generation_id.to_i, row.slot.to_i ] }
        generations_by_id = records_by_id(PokeGeneration, rows.map(&:generation_id))
        abilities_by_id = records_by_id(Ability, rows.map(&:ability_id))

        rows.group_by(&:generation_id)
          .sort
          .map do |generation_id, entries|
            generation = generations_by_id[generation_id]
            next unless generation

            {
              generation: resource_payload(generation, :api_v2_generation_url),
              abilities: entries.map do |row|
                ability = abilities_by_id[row.ability_id]

                {
                  is_hidden: row.is_hidden,
                  slot: row.slot,
                  ability: ability ? resource_payload(ability, :api_v2_ability_url) : nil
                }
              end
            }
          end
          .compact
      end

      def forms_payload(pokemon)
        pokemon.pokemon_forms.sort_by(&:id).map do |pokemon_form|
          resource_payload(pokemon_form, :api_v2_pokemon_form_url)
        end
      end

      def game_indices_payload(pokemon)
        rows = pokemon.pokemon_game_indices.sort_by { |row| [ row.version_id.to_i, row.game_index.to_i ] }
        versions_by_id = records_by_id(PokeVersion, rows.map(&:version_id))

        rows.filter_map do |row|
          version = versions_by_id[row.version_id]
          next unless version

          {
            game_index: row.game_index,
            version: resource_payload(version, :api_v2_version_url)
          }
        end
      end

      def held_items_payload(pokemon)
        rows = pokemon.pokemon_items.sort_by { |row| [ row.item_id.to_i, row.version_id.to_i ] }
        items_by_id = records_by_id(PokeItem, rows.map(&:item_id))
        versions_by_id = records_by_id(PokeVersion, rows.map(&:version_id))

        rows.group_by(&:item_id).sort.map do |item_id, entries|
          item = items_by_id[item_id]
          next unless item

          {
            item: resource_payload(item, :api_v2_item_url),
            version_details: entries.filter_map do |row|
              version = versions_by_id[row.version_id]
              next unless version

              {
                rarity: row.rarity,
                version: resource_payload(version, :api_v2_version_url)
              }
            end
          }
        end.compact
      end

      def moves_payload(pokemon)
        rows = pokemon.pokemon_moves.sort_by do |row|
          [ row.move_id.to_i, row.version_group_id.to_i, row.pokemon_move_method_id.to_i, row.level.to_i ]
        end
        moves_by_id = records_by_id(PokeMove, rows.map(&:move_id))
        version_groups_by_id = records_by_id(PokeVersionGroup, rows.map(&:version_group_id))
        move_learn_methods_by_id = records_by_id(PokeMoveLearnMethod, rows.map(&:pokemon_move_method_id))

        rows.group_by(&:move_id).sort.map do |move_id, entries|
          move = moves_by_id[move_id]
          next unless move

          {
            move: resource_payload(move, :api_v2_move_url),
            version_group_details: entries.filter_map do |row|
              version_group = version_groups_by_id[row.version_group_id]
              move_learn_method = move_learn_methods_by_id[row.pokemon_move_method_id]
              next unless version_group && move_learn_method

              {
                level_learned_at: row.level,
                version_group: resource_payload(version_group, :api_v2_version_group_url),
                move_learn_method: resource_payload(move_learn_method, :api_v2_move_learn_method_url),
                order: row.sort_order
              }
            end
          }
        end.compact
      end

      def past_stats_payload(pokemon)
        rows = pokemon.pokemon_stat_pasts.sort_by { |row| [ row.generation_id.to_i, row.stat_id.to_i ] }
        generations_by_id = records_by_id(PokeGeneration, rows.map(&:generation_id))
        stats_by_id = records_by_id(PokeStat, rows.map(&:stat_id))

        rows.group_by(&:generation_id)
          .sort
          .map do |generation_id, entries|
            generation = generations_by_id[generation_id]
            next unless generation

            {
              generation: resource_payload(generation, :api_v2_generation_url),
              stats: entries.filter_map do |row|
                stat = stats_by_id[row.stat_id]
                next unless stat

                {
                  base_stat: row.base_stat,
                  effort: row.effort,
                  stat: resource_payload(stat, :api_v2_stat_url)
                }
              end
            }
          end
          .compact
      end

      def past_types_payload(pokemon)
        rows = pokemon.pokemon_type_pasts.sort_by { |row| [ row.generation_id.to_i, row.slot.to_i ] }
        generations_by_id = records_by_id(PokeGeneration, rows.map(&:generation_id))
        types_by_id = records_by_id(PokeType, rows.map(&:type_id))

        rows.group_by(&:generation_id)
          .sort
          .map do |generation_id, entries|
            generation = generations_by_id[generation_id]
            next unless generation

            {
              generation: resource_payload(generation, :api_v2_generation_url),
              types: entries.filter_map do |row|
                type = types_by_id[row.type_id]
                next unless type

                {
                  slot: row.slot,
                  type: resource_payload(type, :api_v2_type_url)
                }
              end
            }
          end
          .compact
      end

      def species_payload(species)
        return nil unless species

        resource_payload(species, :api_v2_pokemon_species_url)
      end

      def stats_payload(pokemon)
        rows = pokemon.pokemon_stats.sort_by { |row| row.stat_id.to_i }
        stats_by_id = records_by_id(PokeStat, rows.map(&:stat_id))

        rows.filter_map do |row|
          stat = stats_by_id[row.stat_id]
          next unless stat

          {
            base_stat: row.base_stat,
            effort: row.effort,
            stat: resource_payload(stat, :api_v2_stat_url)
          }
        end
      end

      def types_payload(pokemon)
        rows = pokemon.pokemon_types.sort_by { |row| row.slot.to_i }
        types_by_id = records_by_id(PokeType, rows.map(&:type_id))

        rows.filter_map do |row|
          type = types_by_id[row.type_id]
          next unless type

          {
            slot: row.slot,
            type: resource_payload(type, :api_v2_type_url)
          }
        end
      end

      def cries_payload(pokemon_id)
        {
          latest: "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/#{pokemon_id}.ogg",
          legacy: "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/legacy/#{pokemon_id}.ogg"
        }
      end

      def sprites_payload(pokemon_id, species_or_id)
        female = female_sprite?(species_or_id)

        {
          front_default: sprite_url("sprites/pokemon/#{pokemon_id}.png"),
          front_female: female ? sprite_url("sprites/pokemon/female/#{pokemon_id}.png") : nil,
          front_shiny: sprite_url("sprites/pokemon/shiny/#{pokemon_id}.png"),
          front_shiny_female: female ? sprite_url("sprites/pokemon/shiny/female/#{pokemon_id}.png") : nil,
          back_default: sprite_url("sprites/pokemon/back/#{pokemon_id}.png"),
          back_female: female ? sprite_url("sprites/pokemon/back/female/#{pokemon_id}.png") : nil,
          back_shiny: sprite_url("sprites/pokemon/back/shiny/#{pokemon_id}.png"),
          back_shiny_female: female ? sprite_url("sprites/pokemon/back/shiny/female/#{pokemon_id}.png") : nil,
          other: {
            "dream_world" => {
              front_default: sprite_url("sprites/pokemon/other/dream-world/#{pokemon_id}.svg"),
              front_female: female ? sprite_url("sprites/pokemon/other/dream-world/female/#{pokemon_id}.svg") : nil
            },
            "home" => {
              front_default: sprite_url("sprites/pokemon/other/home/#{pokemon_id}.png"),
              front_female: female ? sprite_url("sprites/pokemon/other/home/female/#{pokemon_id}.png") : nil,
              front_shiny: sprite_url("sprites/pokemon/other/home/shiny/#{pokemon_id}.png"),
              front_shiny_female: female ? sprite_url("sprites/pokemon/other/home/shiny/female/#{pokemon_id}.png") : nil
            },
            "official-artwork" => {
              front_default: sprite_url("sprites/pokemon/other/official-artwork/#{pokemon_id}.png"),
              front_shiny: sprite_url("sprites/pokemon/other/official-artwork/shiny/#{pokemon_id}.png")
            },
            "showdown" => {
              front_default: sprite_url("sprites/pokemon/other/showdown/#{pokemon_id}.gif"),
              front_shiny: sprite_url("sprites/pokemon/other/showdown/shiny/#{pokemon_id}.gif"),
              front_female: female ? sprite_url("sprites/pokemon/other/showdown/female/#{pokemon_id}.gif") : nil,
              front_shiny_female: female ? sprite_url("sprites/pokemon/other/showdown/shiny/female/#{pokemon_id}.gif") : nil,
              back_default: sprite_url("sprites/pokemon/other/showdown/back/#{pokemon_id}.gif"),
              back_shiny: sprite_url("sprites/pokemon/other/showdown/back/shiny/#{pokemon_id}.gif"),
              back_female: female ? sprite_url("sprites/pokemon/other/showdown/back/female/#{pokemon_id}.gif") : nil,
              back_shiny_female: female ? sprite_url("sprites/pokemon/other/showdown/back/shiny/female/#{pokemon_id}.gif") : nil
            }
          },
          versions: versions_sprites_payload(pokemon_id, female)
        }
      end

      def versions_sprites_payload(pokemon_id, female)
        {
          "generation-i" => {
            "red-blue" => {
              front_default: sprite_url("sprites/pokemon/versions/generation-i/red-blue/#{pokemon_id}.png"),
              front_gray: sprite_url("sprites/pokemon/versions/generation-i/red-blue/gray/#{pokemon_id}.png"),
              back_default: sprite_url("sprites/pokemon/versions/generation-i/red-blue/back/#{pokemon_id}.png"),
              back_gray: sprite_url("sprites/pokemon/versions/generation-i/red-blue/back/gray/#{pokemon_id}.png"),
              front_transparent: sprite_url("sprites/pokemon/versions/generation-i/red-blue/transparent/#{pokemon_id}.png"),
              back_transparent: sprite_url("sprites/pokemon/versions/generation-i/red-blue/transparent/back/#{pokemon_id}.png")
            },
            "yellow" => {
              front_default: sprite_url("sprites/pokemon/versions/generation-i/yellow/#{pokemon_id}.png"),
              front_gray: sprite_url("sprites/pokemon/versions/generation-i/yellow/gray/#{pokemon_id}.png"),
              back_default: sprite_url("sprites/pokemon/versions/generation-i/yellow/back/#{pokemon_id}.png"),
              back_gray: sprite_url("sprites/pokemon/versions/generation-i/yellow/back/gray/#{pokemon_id}.png"),
              front_transparent: sprite_url("sprites/pokemon/versions/generation-i/yellow/transparent/#{pokemon_id}.png"),
              back_transparent: sprite_url("sprites/pokemon/versions/generation-i/yellow/transparent/back/#{pokemon_id}.png")
            }
          },
          "generation-ii" => {
            "crystal" => {
              front_default: sprite_url("sprites/pokemon/versions/generation-ii/crystal/#{pokemon_id}.png"),
              front_shiny: sprite_url("sprites/pokemon/versions/generation-ii/crystal/shiny/#{pokemon_id}.png"),
              back_default: sprite_url("sprites/pokemon/versions/generation-ii/crystal/back/#{pokemon_id}.png"),
              back_shiny: sprite_url("sprites/pokemon/versions/generation-ii/crystal/back/shiny/#{pokemon_id}.png"),
              front_transparent: sprite_url("sprites/pokemon/versions/generation-ii/crystal/transparent/#{pokemon_id}.png"),
              front_shiny_transparent: sprite_url("sprites/pokemon/versions/generation-ii/crystal/transparent/shiny/#{pokemon_id}.png"),
              back_transparent: sprite_url("sprites/pokemon/versions/generation-ii/crystal/transparent/back/#{pokemon_id}.png"),
              back_shiny_transparent: sprite_url("sprites/pokemon/versions/generation-ii/crystal/transparent/back/shiny/#{pokemon_id}.png")
            },
            "gold" => {
              front_default: sprite_url("sprites/pokemon/versions/generation-ii/gold/#{pokemon_id}.png"),
              front_shiny: sprite_url("sprites/pokemon/versions/generation-ii/gold/shiny/#{pokemon_id}.png"),
              back_default: sprite_url("sprites/pokemon/versions/generation-ii/gold/back/#{pokemon_id}.png"),
              back_shiny: sprite_url("sprites/pokemon/versions/generation-ii/gold/back/shiny/#{pokemon_id}.png"),
              front_transparent: sprite_url("sprites/pokemon/versions/generation-ii/gold/transparent/#{pokemon_id}.png")
            },
            "silver" => {
              front_default: sprite_url("sprites/pokemon/versions/generation-ii/silver/#{pokemon_id}.png"),
              front_shiny: sprite_url("sprites/pokemon/versions/generation-ii/silver/shiny/#{pokemon_id}.png"),
              back_default: sprite_url("sprites/pokemon/versions/generation-ii/silver/back/#{pokemon_id}.png"),
              back_shiny: sprite_url("sprites/pokemon/versions/generation-ii/silver/back/shiny/#{pokemon_id}.png"),
              front_transparent: sprite_url("sprites/pokemon/versions/generation-ii/silver/transparent/#{pokemon_id}.png")
            }
          },
          "generation-iii" => {
            "emerald" => {
              front_default: sprite_url("sprites/pokemon/versions/generation-iii/emerald/#{pokemon_id}.png"),
              front_shiny: sprite_url("sprites/pokemon/versions/generation-iii/emerald/shiny/#{pokemon_id}.png")
            },
            "firered-leafgreen" => {
              front_default: sprite_url("sprites/pokemon/versions/generation-iii/firered-leafgreen/#{pokemon_id}.png"),
              front_shiny: sprite_url("sprites/pokemon/versions/generation-iii/firered-leafgreen/shiny/#{pokemon_id}.png"),
              back_default: sprite_url("sprites/pokemon/versions/generation-iii/firered-leafgreen/back/#{pokemon_id}.png"),
              back_shiny: sprite_url("sprites/pokemon/versions/generation-iii/firered-leafgreen/back/shiny/#{pokemon_id}.png")
            },
            "ruby-sapphire" => {
              front_default: sprite_url("sprites/pokemon/versions/generation-iii/ruby-sapphire/#{pokemon_id}.png"),
              front_shiny: sprite_url("sprites/pokemon/versions/generation-iii/ruby-sapphire/shiny/#{pokemon_id}.png"),
              back_default: sprite_url("sprites/pokemon/versions/generation-iii/ruby-sapphire/back/#{pokemon_id}.png"),
              back_shiny: sprite_url("sprites/pokemon/versions/generation-iii/ruby-sapphire/back/shiny/#{pokemon_id}.png")
            }
          },
          "generation-iv" => {
            "diamond-pearl" => battle_sprite_payload("generation-iv/diamond-pearl", pokemon_id, female),
            "heartgold-soulsilver" => battle_sprite_payload("generation-iv/heartgold-soulsilver", pokemon_id, female),
            "platinum" => battle_sprite_payload("generation-iv/platinum", pokemon_id, female)
          },
          "generation-v" => {
            "black-white" => battle_sprite_payload("generation-v/black-white", pokemon_id, female).merge(
              animated: battle_animated_sprite_payload("generation-v/black-white/animated", pokemon_id, female)
            )
          },
          "generation-vi" => {
            "omegaruby-alphasapphire" => front_sprite_payload("generation-vi/omegaruby-alphasapphire", pokemon_id, female),
            "x-y" => front_sprite_payload("generation-vi/x-y", pokemon_id, female)
          },
          "generation-vii" => {
            "ultra-sun-ultra-moon" => front_sprite_payload("generation-vii/ultra-sun-ultra-moon", pokemon_id, female),
            "icons" => {
              front_default: sprite_url("sprites/pokemon/versions/generation-vii/icons/#{pokemon_id}.png"),
              front_female: female ? sprite_url("sprites/pokemon/versions/generation-vii/icons/female/#{pokemon_id}.png") : nil
            }
          },
          "generation-viii" => {
            "icons" => {
              front_default: sprite_url("sprites/pokemon/versions/generation-viii/icons/#{pokemon_id}.png"),
              front_female: female ? sprite_url("sprites/pokemon/versions/generation-viii/icons/female/#{pokemon_id}.png") : nil
            },
            "brilliant-diamond-shining-pearl" => {
              front_default: nil,
              front_female: nil
            }
          },
          "generation-ix" => {
            "scarlet-violet" => {
              front_default: nil,
              front_female: nil
            }
          }
        }
      end

      def battle_sprite_payload(version_key, pokemon_id, female)
        {
          front_default: sprite_url("sprites/pokemon/versions/#{version_key}/#{pokemon_id}.png"),
          front_female: female ? sprite_url("sprites/pokemon/versions/#{version_key}/female/#{pokemon_id}.png") : nil,
          front_shiny: sprite_url("sprites/pokemon/versions/#{version_key}/shiny/#{pokemon_id}.png"),
          front_shiny_female: female ? sprite_url("sprites/pokemon/versions/#{version_key}/shiny/female/#{pokemon_id}.png") : nil,
          back_default: sprite_url("sprites/pokemon/versions/#{version_key}/back/#{pokemon_id}.png"),
          back_female: female ? sprite_url("sprites/pokemon/versions/#{version_key}/back/female/#{pokemon_id}.png") : nil,
          back_shiny: sprite_url("sprites/pokemon/versions/#{version_key}/back/shiny/#{pokemon_id}.png"),
          back_shiny_female: female ? sprite_url("sprites/pokemon/versions/#{version_key}/back/shiny/female/#{pokemon_id}.png") : nil
        }
      end

      def battle_animated_sprite_payload(version_key, pokemon_id, female)
        {
          front_default: sprite_url("sprites/pokemon/versions/#{version_key}/#{pokemon_id}.gif"),
          front_female: female ? sprite_url("sprites/pokemon/versions/#{version_key}/female/#{pokemon_id}.gif") : nil,
          front_shiny: sprite_url("sprites/pokemon/versions/#{version_key}/shiny/#{pokemon_id}.gif"),
          front_shiny_female: female ? sprite_url("sprites/pokemon/versions/#{version_key}/shiny/female/#{pokemon_id}.gif") : nil,
          back_default: sprite_url("sprites/pokemon/versions/#{version_key}/back/#{pokemon_id}.gif"),
          back_female: female ? sprite_url("sprites/pokemon/versions/#{version_key}/back/female/#{pokemon_id}.gif") : nil,
          back_shiny: sprite_url("sprites/pokemon/versions/#{version_key}/back/shiny/#{pokemon_id}.gif"),
          back_shiny_female: female ? sprite_url("sprites/pokemon/versions/#{version_key}/back/shiny/female/#{pokemon_id}.gif") : nil
        }
      end

      def front_sprite_payload(version_key, pokemon_id, female)
        {
          front_default: sprite_url("sprites/pokemon/versions/#{version_key}/#{pokemon_id}.png"),
          front_female: female ? sprite_url("sprites/pokemon/versions/#{version_key}/female/#{pokemon_id}.png") : nil,
          front_shiny: sprite_url("sprites/pokemon/versions/#{version_key}/shiny/#{pokemon_id}.png"),
          front_shiny_female: female ? sprite_url("sprites/pokemon/versions/#{version_key}/shiny/female/#{pokemon_id}.png") : nil
        }
      end

      def female_sprite?(species)
        species&.has_gender_differences || false
      end

      def sprite_url(path)
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/#{path}"
      end

      def resource_payload(record, route_helper)
        {
          name: record.name,
          url: "#{public_send(route_helper, record).sub(%r{/+\z}, '')}/"
        }
      end

      def records_by_id(model_class, ids)
        normalized_ids = ids.filter_map { |id| normalized_id(id) }.uniq
        return {} if normalized_ids.empty?

        cache = lookup_cache_for(model_class)
        missing_ids = normalized_ids - cache.keys

        if missing_ids.any?
          loaded = model_class.where(id: missing_ids).index_by(&:id)
          missing_ids.each { |id| cache[id] = loaded[id] }
        end

        normalized_ids.each_with_object({}) do |id, rows|
          record = cache[id]
          rows[id] = record if record
        end
      end

      def lookup_cache_for(model_class)
        @lookup_cache ||= {}
        @lookup_cache[model_class] ||= {}
      end

      def normalized_id(value)
        integer_id = value.to_i
        integer_id.positive? ? integer_id : nil
      end
    end
  end
end
