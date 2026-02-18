module Api
  module V2
    class RootController < BaseController
      def index
        endpoints = {
          ability: canonical_collection_url(api_v2_ability_index_url),
          berry: canonical_collection_url(api_v2_berry_index_url),
          berry_firmness: canonical_collection_url(api_v2_berry_firmness_index_url),
          berry_flavor: canonical_collection_url(api_v2_berry_flavor_index_url),
          characteristic: canonical_collection_url(api_v2_characteristic_index_url),
          contest_effect: canonical_collection_url(api_v2_contest_effect_index_url),
          contest_type: canonical_collection_url(api_v2_contest_type_index_url),
          evolution_chain: canonical_collection_url(api_v2_evolution_chain_index_url),
          evolution_trigger: canonical_collection_url(api_v2_evolution_trigger_index_url),
          encounter_condition: canonical_collection_url(api_v2_encounter_condition_index_url),
          encounter_condition_value: canonical_collection_url(api_v2_encounter_condition_value_index_url),
          encounter_method: canonical_collection_url(api_v2_encounter_method_index_url),
          egg_group: canonical_collection_url(api_v2_egg_group_index_url),
          generation: canonical_collection_url(api_v2_generation_index_url),
          gender: canonical_collection_url(api_v2_gender_index_url),
          growth_rate: canonical_collection_url(api_v2_growth_rate_index_url),
          item: canonical_collection_url(api_v2_item_index_url),
          item_attribute: canonical_collection_url(api_v2_item_attribute_index_url),
          item_category: canonical_collection_url(api_v2_item_category_index_url),
          item_fling_effect: canonical_collection_url(api_v2_item_fling_effect_index_url),
          item_pocket: canonical_collection_url(api_v2_item_pocket_index_url),
          language: canonical_collection_url(api_v2_language_index_url),
          location: canonical_collection_url(api_v2_location_index_url),
          location_area: canonical_collection_url(api_v2_location_area_index_url),
          machine: canonical_collection_url(api_v2_machine_index_url),
          move: canonical_collection_url(api_v2_move_index_url),
          move_ailment: canonical_collection_url(api_v2_move_ailment_index_url),
          move_battle_style: canonical_collection_url(api_v2_move_battle_style_index_url),
          move_category: canonical_collection_url(api_v2_move_category_index_url),
          move_damage_class: canonical_collection_url(api_v2_move_damage_class_index_url),
          move_learn_method: canonical_collection_url(api_v2_move_learn_method_index_url),
          move_target: canonical_collection_url(api_v2_move_target_index_url),
          nature: canonical_collection_url(api_v2_nature_index_url),
          pal_park_area: canonical_collection_url(api_v2_pal_park_area_index_url),
          pokedex: canonical_collection_url(api_v2_pokedex_index_url),
          pokemon: canonical_collection_url(api_v2_pokemon_index_url),
          pokemon_color: canonical_collection_url(api_v2_pokemon_color_index_url),
          pokemon_form: canonical_collection_url(api_v2_pokemon_form_index_url),
          pokemon_habitat: canonical_collection_url(api_v2_pokemon_habitat_index_url),
          pokemon_shape: canonical_collection_url(api_v2_pokemon_shape_index_url),
          pokemon_species: canonical_collection_url(api_v2_pokemon_species_index_url),
          pokeathlon_stat: canonical_collection_url(api_v2_pokeathlon_stat_index_url),
          region: canonical_collection_url(api_v2_region_index_url),
          stat: canonical_collection_url(api_v2_stat_index_url),
          super_contest_effect: canonical_collection_url(api_v2_super_contest_effect_index_url),
          type: canonical_collection_url(api_v2_type_index_url),
          version: canonical_collection_url(api_v2_version_index_url),
          version_group: canonical_collection_url(api_v2_version_group_index_url)
        }

        render json: endpoints.transform_keys { |key| key.to_s.tr("_", "-") }
      end

      private

      def canonical_collection_url(url)
        "#{url.sub(%r{/+\z}, '')}/"
      end
    end
  end
end
