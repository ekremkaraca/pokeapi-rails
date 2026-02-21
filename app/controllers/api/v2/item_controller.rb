module Api
  module V2
    class ItemController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeItem
      RESOURCE_URL_HELPER = :api_v2_item_url

      private

      def detail_payload(item)
        {
          attributes: attributes_payload(item),
          baby_trigger_for: baby_trigger_for_payload(item),
          category: category_payload(item),
          cost: item.cost,
          effect_entries: effect_entries_payload(item),
          flavor_text_entries: flavor_text_entries_payload(item),
          fling_effect: fling_effect_payload(item),
          fling_power: item.fling_power,
          game_indices: game_indices_payload(item),
          held_by_pokemon: held_by_pokemon_payload(item),
          id: item.id,
          machines: machines_payload(item),
          name: item.name,
          names: names_payload(item),
          sprites: sprites_payload(item.name)
        }
      end

      def attributes_payload(item)
        item.item_flag_maps.includes(:item_attribute).order(:item_flag_id).filter_map do |row|
          attribute = row.item_attribute
          next unless attribute

          resource_payload(attribute, :api_v2_item_attribute_url)
        end
      end

      def baby_trigger_for_payload(item)
        chain = item.baby_triggered_evolution_chains.order(:id).first
        return nil unless chain

        { url: "#{api_v2_evolution_chain_url(chain).sub(%r{/+\z}, '')}/" }
      end

      def category_payload(item)
        category = item.category
        return nil unless category

        resource_payload(category, :api_v2_item_category_url)
      end

      def fling_effect_payload(item)
        fling_effect = item.fling_effect
        return nil unless fling_effect

        resource_payload(fling_effect, :api_v2_item_fling_effect_url)
      end

      def effect_entries_payload(item)
        item.item_proses.includes(:local_language).filter_map do |row|
          language = row.local_language
          next unless language

          {
            effect: normalize_prose(row.effect),
            short_effect: normalize_prose(row.short_effect),
            language: resource_payload(language, :api_v2_language_url)
          }
        end
      end

      def flavor_text_entries_payload(item)
        item.item_flavor_texts.includes(:language, :version_group).filter_map do |row|
          language = row.language
          version_group = row.version_group
          next unless language && version_group

          {
            text: row.flavor_text,
            language: resource_payload(language, :api_v2_language_url),
            version_group: resource_payload(version_group, :api_v2_version_group_url)
          }
        end
      end

      def game_indices_payload(item)
        item.item_game_indices.includes(:generation).filter_map do |row|
          generation = row.generation
          next unless generation

          {
            game_index: row.game_index,
            generation: resource_payload(generation, :api_v2_generation_url)
          }
        end
      end

      def held_by_pokemon_payload(item)
        rows = item.pokemon_items.includes(:pokemon, :version).order(:pokemon_id, :version_id)

        rows.group_by(&:pokemon_id).sort.map do |_pokemon_id, entries|
          pokemon = entries.first&.pokemon
          next unless pokemon

          {
            pokemon: resource_payload(pokemon, :api_v2_pokemon_url),
            version_details: entries.filter_map do |entry|
              version = entry.version
              next unless version

              {
                rarity: entry.rarity,
                version: resource_payload(version, :api_v2_version_url)
              }
            end
          }
        end.compact
      end

      def machines_payload(item)
        item.machines.includes(:move, :version_group).order(:id).filter_map do |machine|
          move = machine.move
          version_group = machine.version_group
          next unless move && version_group

          {
            machine: { url: "#{api_v2_machine_url(machine).sub(%r{/+\z}, '')}/" },
            version_group: resource_payload(version_group, :api_v2_version_group_url),
            move: resource_payload(move, :api_v2_move_url)
          }
        end
      end

      def names_payload(item)
        item.item_names.includes(:local_language).filter_map do |row|
          language = row.local_language
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

      def normalize_prose(value)
        return value if value.nil?

        value
          .gsub(/\[([^\]]+)\]\{[^}]+\}/, '\1')
          .gsub(/\[\]\{[^}]+\}/, "")
      end
    end
  end
end
