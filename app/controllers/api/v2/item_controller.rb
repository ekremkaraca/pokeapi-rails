module Api
  module V2
    class ItemController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeItem
      RESOURCE_URL_HELPER = :api_v2_item_url

      private

      def detail_payload(item)
        {
          attributes: attributes_payload(item.id),
          baby_trigger_for: baby_trigger_for_payload(item.id),
          category: category_payload(item.category_id),
          cost: item.cost,
          effect_entries: effect_entries_payload(item.id),
          flavor_text_entries: flavor_text_entries_payload(item.id),
          fling_effect: fling_effect_payload(item.fling_effect_id),
          fling_power: item.fling_power,
          game_indices: game_indices_payload(item.id),
          held_by_pokemon: held_by_pokemon_payload(item.id),
          id: item.id,
          machines: machines_payload(item.id),
          name: item.name,
          names: names_payload(item.id),
          sprites: sprites_payload(item.name)
        }
      end

      def attributes_payload(item_id)
        attribute_ids = PokeItemFlagMap.where(item_id: item_id).pluck(:item_flag_id).uniq
        PokeItemAttribute.where(id: attribute_ids).order(:id).map do |attribute|
          resource_payload(attribute, :api_v2_item_attribute_url)
        end
      end

      def baby_trigger_for_payload(item_id)
        chain = PokeEvolutionChain.find_by(baby_trigger_item_id: item_id)
        return nil unless chain

        { url: "#{api_v2_evolution_chain_url(chain).sub(%r{/+\z}, '')}/" }
      end

      def category_payload(category_id)
        category = PokeItemCategory.find_by(id: category_id)
        return nil unless category

        resource_payload(category, :api_v2_item_category_url)
      end

      def fling_effect_payload(fling_effect_id)
        fling_effect = PokeItemFlingEffect.find_by(id: fling_effect_id)
        return nil unless fling_effect

        resource_payload(fling_effect, :api_v2_item_fling_effect_url)
      end

      def effect_entries_payload(item_id)
        rows = PokeItemProse.where(item_id: item_id)
        languages_by_id = records_by_id(PokeLanguage, rows.map(&:local_language_id))

        rows.filter_map do |row|
          language = languages_by_id[row.local_language_id]
          next unless language

          {
            effect: normalize_prose(row.effect),
            short_effect: normalize_prose(row.short_effect),
            language: resource_payload(language, :api_v2_language_url)
          }
        end
      end

      def flavor_text_entries_payload(item_id)
        rows = PokeItemFlavorText.where(item_id: item_id)
        languages_by_id = records_by_id(PokeLanguage, rows.map(&:language_id))
        version_groups_by_id = records_by_id(PokeVersionGroup, rows.map(&:version_group_id))

        rows.filter_map do |row|
          language = languages_by_id[row.language_id]
          version_group = version_groups_by_id[row.version_group_id]
          next unless language && version_group

          {
            text: row.flavor_text,
            language: resource_payload(language, :api_v2_language_url),
            version_group: resource_payload(version_group, :api_v2_version_group_url)
          }
        end
      end

      def game_indices_payload(item_id)
        rows = PokeItemGameIndex.where(item_id: item_id)
        generations_by_id = records_by_id(PokeGeneration, rows.map(&:generation_id))

        rows.filter_map do |row|
          generation = generations_by_id[row.generation_id]
          next unless generation

          {
            game_index: row.game_index,
            generation: resource_payload(generation, :api_v2_generation_url)
          }
        end
      end

      def held_by_pokemon_payload(item_id)
        rows = PokePokemonItem.where(item_id: item_id).order(:pokemon_id, :version_id)
        pokemons_by_id = records_by_id(Pokemon, rows.map(&:pokemon_id))
        versions_by_id = records_by_id(PokeVersion, rows.map(&:version_id))

        rows.group_by(&:pokemon_id).sort.map do |pokemon_id, entries|
          pokemon = pokemons_by_id[pokemon_id]
          next unless pokemon

          {
            pokemon: resource_payload(pokemon, :api_v2_pokemon_url),
            version_details: entries.filter_map do |entry|
              version = versions_by_id[entry.version_id]
              next unless version

              {
                rarity: entry.rarity,
                version: resource_payload(version, :api_v2_version_url)
              }
            end
          }
        end.compact
      end

      def machines_payload(item_id)
        machines = PokeMachine.where(item_id: item_id).order(:id)
        moves_by_id = records_by_id(PokeMove, machines.map(&:move_id))
        version_groups_by_id = records_by_id(PokeVersionGroup, machines.map(&:version_group_id))

        machines.filter_map do |machine|
          move = moves_by_id[machine.move_id]
          version_group = version_groups_by_id[machine.version_group_id]
          next unless move && version_group

          {
            machine: { url: "#{api_v2_machine_url(machine).sub(%r{/+\z}, '')}/" },
            version_group: resource_payload(version_group, :api_v2_version_group_url),
            move: resource_payload(move, :api_v2_move_url)
          }
        end
      end

      def names_payload(item_id)
        rows = PokeItemName.where(item_id: item_id)
        languages_by_id = records_by_id(PokeLanguage, rows.map(&:local_language_id))

        rows.filter_map do |row|
          language = languages_by_id[row.local_language_id]
          next unless language

          {
            name: row.name,
            language: resource_payload(language, :api_v2_language_url)
          }
        end
      end

      def sprites_payload(item_name)
        {
          default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/#{item_name}.png"
        }
      end

      def resource_payload(record, route_helper)
        {
          name: record.name,
          url: "#{public_send(route_helper, record).sub(%r{/+\z}, '')}/"
        }
      end

      def records_by_id(model_class, ids)
        model_class.where(id: ids.uniq).index_by(&:id)
      end

      def normalize_prose(value)
        return value if value.nil?

        value
          .gsub(/\[([^\]]+)\]\{[^}]+\}/, '\1')
          .gsub(/\[\]\{[^}]+\}/, "")
      end
    end
  end
end
