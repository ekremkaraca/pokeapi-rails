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
          game_indices: game_indices_for(type),
          generation: generation_payload(type),
          id: type.id,
          move_damage_class: move_damage_class_payload(type),
          moves: moves_for(type),
          name: type.name,
          names: names_for(type),
          past_damage_relations: past_damage_relations_for(type.id),
          pokemon: pokemon_for(type),
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
        rows = PokeTypeEfficacy
          .where("damage_type_id = ? OR target_type_id = ?", type_id, type_id)
          .includes(:damage_type, :target_type)

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
        rows = PokeTypeEfficacyPast
          .where("damage_type_id = ? OR target_type_id = ?", type_id, type_id)
          .includes(:generation)

        rows.group_by(&:generation_id).sort.map do |generation_id, generation_rows|
          generation = generation_rows.first&.generation

          {
            generation: generation ? resource_payload(generation, :api_v2_generation_url) : nil,
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

      def game_indices_for(type)
        rows = type.type_game_indices.includes(:generation)

        rows.filter_map do |row|
          generation = row.generation
          next unless generation

          {
            game_index: row.game_index,
            generation: resource_payload(generation, :api_v2_generation_url)
          }
        end
      end

      def names_for(type)
        rows = type.type_names.includes(:local_language)

        rows.filter_map do |row|
          language = row.local_language
          next unless language

          {
            name: row.name,
            language: resource_payload(language, :api_v2_language_url)
          }
        end
      end

      def moves_for(type)
        type.moves.order(:id).map do |move|
          resource_payload(move, :api_v2_move_url)
        end
      end

      def pokemon_for(type)
        type.pokemon_types.includes(:pokemon).order(:pokemon_id, :slot).filter_map do |row|
          pokemon = row.pokemon
          next unless pokemon

          {
            slot: row.slot,
            pokemon: resource_payload(pokemon, :api_v2_pokemon_url)
          }
        end
      end

      def generation_payload(type)
        generation = type.generation
        return nil unless generation

        resource_payload(generation, :api_v2_generation_url)
      end

      def move_damage_class_payload(type)
        damage_class = type.damage_class
        return nil unless damage_class

        resource_payload(damage_class, :api_v2_move_damage_class_url)
      end

      def relation_targets(rows, source_key:, source_id:, target_key:, factor:)
        target_assoc = target_key == "target_type_id" ? :target_type : :damage_type

        rows.select do |row|
          row.public_send(source_key) == source_id && row.damage_factor == factor
        end.sort_by { |row| row.public_send(target_key) }
          .filter_map do |row|
          type = row.public_send(target_assoc)
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
    end
  end
end
