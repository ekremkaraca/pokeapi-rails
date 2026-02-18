module Api
  module V2
    class TypeController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeType
      RESOURCE_URL_HELPER = :api_v2_type_url

      private

      def detail_payload(type)
        {
          damage_relations: damage_relations_for(type.id),
          game_indices: game_indices_for(type.id),
          generation: generation_payload(type.generation_id),
          id: type.id,
          move_damage_class: move_damage_class_payload(type.damage_class_id),
          moves: moves_for(type.id),
          name: type.name,
          names: names_for(type.id),
          past_damage_relations: past_damage_relations_for(type.id),
          pokemon: pokemon_for(type.id),
          sprites: sprites_payload(type.id)
        }
      end

      def sprites_payload(type_id)
        {
          "generation-iii" => {
            "colosseum" => sprite_entry("generation-iii", "colosseum", type_id),
            "emerald" => sprite_entry("generation-iii", "emerald", type_id),
            "firered-leafgreen" => sprite_entry("generation-iii", "firered-leafgreen", type_id),
            "ruby-sapphire" => sprite_entry("generation-iii", "ruby-sapphire", type_id),
            "xd" => sprite_entry("generation-iii", "xd", type_id)
          },
          "generation-iv" => {
            "diamond-pearl" => sprite_entry("generation-iv", "diamond-pearl", type_id),
            "heartgold-soulsilver" => sprite_entry("generation-iv", "heartgold-soulsilver", type_id),
            "platinum" => sprite_entry("generation-iv", "platinum", type_id)
          },
          "generation-v" => {
            "black-2-white-2" => sprite_entry("generation-v", "black-2-white-2", type_id),
            "black-white" => sprite_entry("generation-v", "black-white", type_id)
          },
          "generation-vi" => {
            "omega-ruby-alpha-sapphire" => sprite_entry("generation-vi", "omega-ruby-alpha-sapphire", type_id),
            "x-y" => sprite_entry("generation-vi", "x-y", type_id)
          },
          "generation-vii" => {
            "lets-go-pikachu-lets-go-eevee" => sprite_entry("generation-vii", "lets-go-pikachu-lets-go-eevee", type_id),
            "sun-moon" => sprite_entry("generation-vii", "sun-moon", type_id),
            "ultra-sun-ultra-moon" => sprite_entry("generation-vii", "ultra-sun-ultra-moon", type_id)
          },
          "generation-viii" => {
            "brilliant-diamond-shining-pearl" => sprite_entry("generation-viii", "brilliant-diamond-shining-pearl", type_id),
            "legends-arceus" => sprite_entry("generation-viii", "legends-arceus", type_id),
            "sword-shield" => sprite_entry("generation-viii", "sword-shield", type_id)
          },
          "generation-ix" => {
            "scarlet-violet" => sprite_entry("generation-ix", "scarlet-violet", type_id)
          }
        }
      end

      def damage_relations_for(type_id)
        rows = PokeTypeEfficacy.where("damage_type_id = ? OR target_type_id = ?", type_id, type_id)

        {
          no_damage_to: relation_targets(rows, source_key: "damage_type_id", source_id: type_id, target_key: "target_type_id", factor: 0),
          half_damage_to: relation_targets(rows, source_key: "damage_type_id", source_id: type_id, target_key: "target_type_id", factor: 50),
          double_damage_to: relation_targets(rows, source_key: "damage_type_id", source_id: type_id, target_key: "target_type_id", factor: 200),
          no_damage_from: relation_targets(rows, source_key: "target_type_id", source_id: type_id, target_key: "damage_type_id", factor: 0),
          half_damage_from: relation_targets(rows, source_key: "target_type_id", source_id: type_id, target_key: "damage_type_id", factor: 50),
          double_damage_from: relation_targets(rows, source_key: "target_type_id", source_id: type_id, target_key: "damage_type_id", factor: 200)
        }
      end

      def past_damage_relations_for(type_id)
        rows = PokeTypeEfficacyPast.where("damage_type_id = ? OR target_type_id = ?", type_id, type_id)

        rows.group_by(&:generation_id).sort.map do |generation_id, generation_rows|
          {
            generation: generation_payload(generation_id),
            damage_relations: {
              no_damage_to: relation_targets(generation_rows, source_key: "damage_type_id", source_id: type_id, target_key: "target_type_id", factor: 0),
              half_damage_to: relation_targets(generation_rows, source_key: "damage_type_id", source_id: type_id, target_key: "target_type_id", factor: 50),
              double_damage_to: relation_targets(generation_rows, source_key: "damage_type_id", source_id: type_id, target_key: "target_type_id", factor: 200),
              no_damage_from: relation_targets(generation_rows, source_key: "target_type_id", source_id: type_id, target_key: "damage_type_id", factor: 0),
              half_damage_from: relation_targets(generation_rows, source_key: "target_type_id", source_id: type_id, target_key: "damage_type_id", factor: 50),
              double_damage_from: relation_targets(generation_rows, source_key: "target_type_id", source_id: type_id, target_key: "damage_type_id", factor: 200)
            }
          }
        end
      end

      def game_indices_for(type_id)
        rows = PokeTypeGameIndex.where(type_id: type_id)
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

      def names_for(type_id)
        rows = PokeTypeName.where(type_id: type_id)
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

      def moves_for(type_id)
        PokeMove.where(type_id: type_id).order(:id).map do |move|
          resource_payload(move, :api_v2_move_url)
        end
      end

      def pokemon_for(type_id)
        rows = PokePokemonType.where(type_id: type_id).order(:pokemon_id, :slot)
        pokemons_by_id = records_by_id(Pokemon, rows.map(&:pokemon_id))

        rows.filter_map do |row|
          pokemon = pokemons_by_id[row.pokemon_id]
          next unless pokemon

          {
            slot: row.slot,
            pokemon: resource_payload(pokemon, :api_v2_pokemon_url)
          }
        end
      end

      def generation_payload(generation_id)
        generation = PokeGeneration.find_by(id: generation_id)
        return nil unless generation

        resource_payload(generation, :api_v2_generation_url)
      end

      def move_damage_class_payload(damage_class_id)
        damage_class = PokeMoveDamageClass.find_by(id: damage_class_id)
        return nil unless damage_class

        resource_payload(damage_class, :api_v2_move_damage_class_url)
      end

      def relation_targets(rows, source_key:, source_id:, target_key:, factor:)
        matching_target_ids = rows.select do |row|
          row.public_send(source_key) == source_id && row.damage_factor == factor
        end.map { |row| row.public_send(target_key) }.uniq

        types_by_id = records_by_id(PokeType, matching_target_ids)
        matching_target_ids.sort.filter_map do |type_id|
          type = types_by_id[type_id]
          next unless type

          resource_payload(type, :api_v2_type_url)
        end
      end

      def resource_payload(record, route_helper)
        {
          name: record.name,
          url: "#{public_send(route_helper, record).sub(%r{/+\z}, '')}/"
        }
      end

      def sprite_entry(generation_key, version_key, type_id)
        return { "name_icon" => nil } if generation_key == "generation-viii" && version_key == "brilliant-diamond-shining-pearl"

        {
          "name_icon" => "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/#{generation_key}/#{version_key}/#{type_id}.png"
        }
      end

      def records_by_id(model_class, ids)
        model_class.where(id: ids.uniq).index_by(&:id)
      end
    end
  end
end
