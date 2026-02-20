require Rails.root.join("lib/pokeapi/contract/openapi_drift")
require Rails.root.join("lib/pokeapi/contract/report_formatter")
require Rails.root.join("lib/pokeapi/contract/openapi_validator")
require Rails.root.join("lib/pokeapi/contract/v3_budget_checker")

namespace :pokeapi do
  namespace :contract do
    desc "Compare source OpenAPI paths/methods against Rails /api/v2 routes"
    task drift: :environment do
      source_openapi_path = ENV.fetch("SOURCE_OPENAPI_PATH", File.expand_path("../pokeapi/openapi.yml", Rails.root))
      max_items = ENV.fetch("MAX_ITEMS", "200").to_i
      output_format = ENV.fetch("OUTPUT_FORMAT", "text").to_s.strip.downcase

      unless File.exist?(source_openapi_path)
        raise "SOURCE_OPENAPI_PATH not found: #{source_openapi_path}"
      end

      result = Pokeapi::Contract::OpenapiDrift.new(source_openapi_path: source_openapi_path).run

      formatter = Pokeapi::Contract::ReportFormatter.new(result: result, max_items: max_items, task_name: "pokeapi:contract:drift")

      case output_format
      when "text"
        puts formatter.text
      when "json"
        puts formatter.json
      else
        raise "Unsupported OUTPUT_FORMAT=#{output_format.inspect} (expected: text or json)"
      end

      raise "Contract drift detected" unless result[:matches]
    end

    desc "Compare /api/v3 OpenAPI paths/methods against Rails /api/v3 routes"
    task drift_v3: :environment do
      source_openapi_path = ENV.fetch("V3_OPENAPI_PATH", Rails.root.join("public/openapi-v3.yml").to_s)
      max_items = ENV.fetch("MAX_ITEMS", "200").to_i
      output_format = ENV.fetch("OUTPUT_FORMAT", "text").to_s.strip.downcase

      unless File.exist?(source_openapi_path)
        raise "V3_OPENAPI_PATH not found: #{source_openapi_path}"
      end

      result = Pokeapi::Contract::OpenapiDrift.new(
        source_openapi_path: source_openapi_path,
        api_prefix: "/api/v3",
        ignored_paths: []
      ).run

      formatter = Pokeapi::Contract::ReportFormatter.new(
        result: result,
        max_items: max_items,
        task_name: "pokeapi:contract:drift_v3"
      )

      case output_format
      when "text"
        puts formatter.text
      when "json"
        puts formatter.json
      else
        raise "Unsupported OUTPUT_FORMAT=#{output_format.inspect} (expected: text or json)"
      end

      raise "Contract drift detected" unless result[:matches]
    end

    desc "Validate /api/v3 OpenAPI skeleton contract file"
    task :validate_v3_openapi do
      openapi_path = ENV.fetch("V3_OPENAPI_PATH", Rails.root.join("public/openapi-v3.yml").to_s)
      validator = Pokeapi::Contract::OpenapiValidator.new(path: openapi_path)
      validator.validate
      puts "Validated v3 OpenAPI: #{openapi_path}"
    end

    desc "Check /api/v3 endpoint query/latency budgets using observability headers"
    task check_v3_budgets: :environment do
      output_format = ENV.fetch("OUTPUT_FORMAT", "text").to_s.strip.downcase

      pokemon_id = Pokemon.order(:id).pick(:id)
      ability_id = Ability.order(:id).pick(:id)
      type_id = PokeType.order(:id).pick(:id)
      move_id = PokeMove.order(:id).pick(:id)
      item_id = PokeItem.order(:id).pick(:id)
      generation_id = PokeGeneration.order(:id).pick(:id)
      version_group_id = PokeVersionGroup.order(:id).pick(:id)
      region_id = PokeRegion.order(:id).pick(:id)
      version_id = PokeVersion.order(:id).pick(:id)
      species_id = PokePokemonSpecies.order(:id).pick(:id)
      evolution_chain_id = PokeEvolutionChain.order(:id).pick(:id)
      evolution_trigger_id = PokeEvolutionTrigger.order(:id).pick(:id)
      growth_rate_id = PokeGrowthRate.order(:id).pick(:id)
      nature_id = PokeNature.order(:id).pick(:id)
      gender_id = PokeGender.order(:id).pick(:id)
      egg_group_id = PokeEggGroup.order(:id).pick(:id)
      encounter_method_id = PokeEncounterMethod.order(:id).pick(:id)
      encounter_condition_id = PokeEncounterCondition.order(:id).pick(:id)
      encounter_condition_value_id = PokeEncounterConditionValue.order(:id).pick(:id)
      berry_id = PokeBerry.order(:id).pick(:id)
      berry_firmness_id = PokeBerryFirmness.order(:id).pick(:id)
      berry_flavor_id = PokeBerryFlavor.order(:id).pick(:id)
      contest_type_id = PokeContestType.order(:id).pick(:id)
      contest_effect_id = PokeContestEffect.order(:id).pick(:id)
      item_category_id = PokeItemCategory.order(:id).pick(:id)
      item_pocket_id = PokeItemPocket.order(:id).pick(:id)
      item_attribute_id = PokeItemAttribute.order(:id).pick(:id)
      item_fling_effect_id = PokeItemFlingEffect.order(:id).pick(:id)
      language_id = PokeLanguage.order(:id).pick(:id)
      location_id = PokeLocation.order(:id).pick(:id)
      location_area_id = PokeLocationArea.order(:id).pick(:id)
      machine_id = PokeMachine.order(:id).pick(:id)
      move_ailment_id = PokeMoveAilment.order(:id).pick(:id)
      move_battle_style_id = PokeMoveBattleStyle.order(:id).pick(:id)
      move_category_id = PokeMoveMetaCategory.order(:id).pick(:id)
      move_damage_class_id = PokeMoveDamageClass.order(:id).pick(:id)
      move_learn_method_id = PokeMoveLearnMethod.order(:id).pick(:id)
      move_target_id = PokeMoveTarget.order(:id).pick(:id)
      characteristic_id = PokeCharacteristic.order(:id).pick(:id)
      stat_id = PokeStat.order(:id).pick(:id)
      super_contest_effect_id = PokeSuperContestEffect.order(:id).pick(:id)
      pal_park_area_id = PokePalParkArea.order(:id).pick(:id)
      pokeathlon_stat_id = PokePokeathlonStat.order(:id).pick(:id)
      pokedex_id = PokePokedex.order(:id).pick(:id)
      pokemon_color_id = PokePokemonColor.order(:id).pick(:id)
      pokemon_form_id = PokePokemonForm.order(:id).pick(:id)
      pokemon_habitat_id = PokePokemonHabitat.order(:id).pick(:id)
      pokemon_shape_id = PokePokemonShape.order(:id).pick(:id)

      unless pokemon_id && ability_id && type_id && move_id && item_id && generation_id && version_group_id && region_id && version_id && species_id && evolution_chain_id && evolution_trigger_id && growth_rate_id && nature_id && gender_id && egg_group_id && encounter_method_id && encounter_condition_id && encounter_condition_value_id && berry_id && berry_firmness_id && berry_flavor_id && contest_type_id && contest_effect_id && item_category_id && item_pocket_id && item_attribute_id && item_fling_effect_id && language_id && location_id && location_area_id && machine_id && move_ailment_id && move_battle_style_id && move_category_id && move_damage_class_id && move_learn_method_id && move_target_id && characteristic_id && stat_id && super_contest_effect_id && pal_park_area_id && pokeathlon_stat_id && pokedex_id && pokemon_color_id && pokemon_form_id && pokemon_habitat_id && pokemon_shape_id
        raise "Missing seed data for v3 budget checks. Expected pokemon/ability/type/move/item/generation/version-group/region/version/pokemon-species/evolution-chain/evolution-trigger/growth-rate/nature/gender/egg-group/encounter-method/encounter-condition/encounter-condition-value/berry/berry-firmness/berry-flavor/contest-type/contest-effect/item-category/item-pocket/item-attribute/item-fling-effect/language/location/location-area/machine/move-ailment/move-battle-style/move-category/move-damage-class/move-learn-method/move-target/characteristic/stat/super-contest-effect/pal-park-area/pokeathlon-stat/pokedex/pokemon-color/pokemon-form/pokemon-habitat/pokemon-shape rows to exist."
      end

      scenarios = [
        { name: "pokemon_list", path: "/api/v3/pokemon?limit=20", kind: :list, include: false },
        { name: "pokemon_detail", path: "/api/v3/pokemon/#{pokemon_id}", kind: :detail, include: false },
        { name: "pokemon_list_include", path: "/api/v3/pokemon?limit=20&include=abilities", kind: :list, include: true },
        { name: "pokemon_detail_include", path: "/api/v3/pokemon/#{pokemon_id}?include=abilities", kind: :detail, include: true },
        { name: "ability_list", path: "/api/v3/ability?limit=20", kind: :list, include: false },
        { name: "ability_detail", path: "/api/v3/ability/#{ability_id}", kind: :detail, include: false },
        { name: "ability_list_include", path: "/api/v3/ability?limit=20&include=pokemon", kind: :list, include: true },
        { name: "ability_detail_include", path: "/api/v3/ability/#{ability_id}?include=pokemon", kind: :detail, include: true },
        { name: "type_list", path: "/api/v3/type?limit=20", kind: :list, include: false },
        { name: "type_detail", path: "/api/v3/type/#{type_id}", kind: :detail, include: false },
        { name: "type_list_include", path: "/api/v3/type?limit=20&include=pokemon", kind: :list, include: true },
        { name: "type_detail_include", path: "/api/v3/type/#{type_id}?include=pokemon", kind: :detail, include: true },
        { name: "move_list", path: "/api/v3/move?limit=20", kind: :list, include: false },
        { name: "move_detail", path: "/api/v3/move/#{move_id}", kind: :detail, include: false },
        { name: "move_list_include", path: "/api/v3/move?limit=20&include=pokemon", kind: :list, include: true },
        { name: "move_detail_include", path: "/api/v3/move/#{move_id}?include=pokemon", kind: :detail, include: true },
        { name: "item_list", path: "/api/v3/item?limit=20", kind: :list, include: false },
        { name: "item_detail", path: "/api/v3/item/#{item_id}", kind: :detail, include: false },
        { name: "item_list_include", path: "/api/v3/item?limit=20&include=category", kind: :list, include: true },
        { name: "item_detail_include", path: "/api/v3/item/#{item_id}?include=category", kind: :detail, include: true },
        { name: "generation_list", path: "/api/v3/generation?limit=20", kind: :list, include: false },
        { name: "generation_detail", path: "/api/v3/generation/#{generation_id}", kind: :detail, include: false },
        { name: "generation_list_include", path: "/api/v3/generation?limit=20&include=main_region", kind: :list, include: true },
        { name: "generation_detail_include", path: "/api/v3/generation/#{generation_id}?include=main_region", kind: :detail, include: true },
        { name: "version_group_list", path: "/api/v3/version-group?limit=20", kind: :list, include: false },
        { name: "version_group_detail", path: "/api/v3/version-group/#{version_group_id}", kind: :detail, include: false },
        { name: "version_group_list_include", path: "/api/v3/version-group?limit=20&include=generation", kind: :list, include: true },
        { name: "version_group_detail_include", path: "/api/v3/version-group/#{version_group_id}?include=generation", kind: :detail, include: true },
        { name: "region_list", path: "/api/v3/region?limit=20", kind: :list, include: false },
        { name: "region_detail", path: "/api/v3/region/#{region_id}", kind: :detail, include: false },
        { name: "region_list_include", path: "/api/v3/region?limit=20&include=generations", kind: :list, include: true },
        { name: "region_detail_include", path: "/api/v3/region/#{region_id}?include=generations", kind: :detail, include: true },
        { name: "version_list", path: "/api/v3/version?limit=20", kind: :list, include: false },
        { name: "version_detail", path: "/api/v3/version/#{version_id}", kind: :detail, include: false },
        { name: "version_list_include", path: "/api/v3/version?limit=20&include=version_group", kind: :list, include: true },
        { name: "version_detail_include", path: "/api/v3/version/#{version_id}?include=version_group", kind: :detail, include: true },
        { name: "pokemon_species_list", path: "/api/v3/pokemon-species?limit=20", kind: :list, include: false },
        { name: "pokemon_species_detail", path: "/api/v3/pokemon-species/#{species_id}", kind: :detail, include: false },
        { name: "pokemon_species_list_include", path: "/api/v3/pokemon-species?limit=20&include=generation", kind: :list, include: true },
        { name: "pokemon_species_detail_include", path: "/api/v3/pokemon-species/#{species_id}?include=generation", kind: :detail, include: true },
        { name: "evolution_chain_list", path: "/api/v3/evolution-chain?limit=20", kind: :list, include: false },
        { name: "evolution_chain_detail", path: "/api/v3/evolution-chain/#{evolution_chain_id}", kind: :detail, include: false },
        { name: "evolution_chain_list_include", path: "/api/v3/evolution-chain?limit=20&include=pokemon_species", kind: :list, include: true },
        { name: "evolution_chain_detail_include", path: "/api/v3/evolution-chain/#{evolution_chain_id}?include=pokemon_species", kind: :detail, include: true },
        { name: "evolution_trigger_list", path: "/api/v3/evolution-trigger?limit=20", kind: :list, include: false },
        { name: "evolution_trigger_detail", path: "/api/v3/evolution-trigger/#{evolution_trigger_id}", kind: :detail, include: false },
        { name: "growth_rate_list", path: "/api/v3/growth-rate?limit=20", kind: :list, include: false },
        { name: "growth_rate_detail", path: "/api/v3/growth-rate/#{growth_rate_id}", kind: :detail, include: false },
        { name: "nature_list", path: "/api/v3/nature?limit=20", kind: :list, include: false },
        { name: "nature_detail", path: "/api/v3/nature/#{nature_id}", kind: :detail, include: false },
        { name: "gender_list", path: "/api/v3/gender?limit=20", kind: :list, include: false },
        { name: "gender_detail", path: "/api/v3/gender/#{gender_id}", kind: :detail, include: false },
        { name: "egg_group_list", path: "/api/v3/egg-group?limit=20", kind: :list, include: false },
        { name: "egg_group_detail", path: "/api/v3/egg-group/#{egg_group_id}", kind: :detail, include: false },
        { name: "encounter_method_list", path: "/api/v3/encounter-method?limit=20", kind: :list, include: false },
        { name: "encounter_method_detail", path: "/api/v3/encounter-method/#{encounter_method_id}", kind: :detail, include: false },
        { name: "encounter_condition_list", path: "/api/v3/encounter-condition?limit=20", kind: :list, include: false },
        { name: "encounter_condition_detail", path: "/api/v3/encounter-condition/#{encounter_condition_id}", kind: :detail, include: false },
        { name: "encounter_condition_value_list", path: "/api/v3/encounter-condition-value?limit=20", kind: :list, include: false },
        { name: "encounter_condition_value_detail", path: "/api/v3/encounter-condition-value/#{encounter_condition_value_id}", kind: :detail, include: false },
        { name: "berry_list", path: "/api/v3/berry?limit=20", kind: :list, include: false },
        { name: "berry_detail", path: "/api/v3/berry/#{berry_id}", kind: :detail, include: false },
        { name: "berry_firmness_list", path: "/api/v3/berry-firmness?limit=20", kind: :list, include: false },
        { name: "berry_firmness_detail", path: "/api/v3/berry-firmness/#{berry_firmness_id}", kind: :detail, include: false },
        { name: "berry_firmness_list_include", path: "/api/v3/berry-firmness?limit=20&include=berries", kind: :list, include: true },
        { name: "berry_firmness_detail_include", path: "/api/v3/berry-firmness/#{berry_firmness_id}?include=berries", kind: :detail, include: true },
        { name: "berry_flavor_list", path: "/api/v3/berry-flavor?limit=20", kind: :list, include: false },
        { name: "berry_flavor_detail", path: "/api/v3/berry-flavor/#{berry_flavor_id}", kind: :detail, include: false },
        { name: "berry_flavor_list_include", path: "/api/v3/berry-flavor?limit=20&include=contest_type", kind: :list, include: true },
        { name: "berry_flavor_detail_include", path: "/api/v3/berry-flavor/#{berry_flavor_id}?include=contest_type", kind: :detail, include: true },
        { name: "contest_type_list", path: "/api/v3/contest-type?limit=20", kind: :list, include: false },
        { name: "contest_type_detail", path: "/api/v3/contest-type/#{contest_type_id}", kind: :detail, include: false },
        { name: "contest_type_list_include", path: "/api/v3/contest-type?limit=20&include=berry_flavors", kind: :list, include: true },
        { name: "contest_type_detail_include", path: "/api/v3/contest-type/#{contest_type_id}?include=berry_flavors", kind: :detail, include: true },
        { name: "contest_effect_list", path: "/api/v3/contest-effect?limit=20", kind: :list, include: false },
        { name: "contest_effect_detail", path: "/api/v3/contest-effect/#{contest_effect_id}", kind: :detail, include: false },
        { name: "contest_effect_list_include", path: "/api/v3/contest-effect?limit=20&include=moves", kind: :list, include: true },
        { name: "contest_effect_detail_include", path: "/api/v3/contest-effect/#{contest_effect_id}?include=moves", kind: :detail, include: true },
        { name: "item_category_list", path: "/api/v3/item-category?limit=20", kind: :list, include: false },
        { name: "item_category_detail", path: "/api/v3/item-category/#{item_category_id}", kind: :detail, include: false },
        { name: "item_category_list_include", path: "/api/v3/item-category?limit=20&include=pocket", kind: :list, include: true },
        { name: "item_category_detail_include", path: "/api/v3/item-category/#{item_category_id}?include=pocket", kind: :detail, include: true },
        { name: "item_pocket_list", path: "/api/v3/item-pocket?limit=20", kind: :list, include: false },
        { name: "item_pocket_detail", path: "/api/v3/item-pocket/#{item_pocket_id}", kind: :detail, include: false },
        { name: "item_pocket_list_include", path: "/api/v3/item-pocket?limit=20&include=item_categories", kind: :list, include: true },
        { name: "item_pocket_detail_include", path: "/api/v3/item-pocket/#{item_pocket_id}?include=item_categories", kind: :detail, include: true },
        { name: "item_attribute_list", path: "/api/v3/item-attribute?limit=20", kind: :list, include: false },
        { name: "item_attribute_detail", path: "/api/v3/item-attribute/#{item_attribute_id}", kind: :detail, include: false },
        { name: "item_attribute_list_include", path: "/api/v3/item-attribute?limit=20&include=items", kind: :list, include: true },
        { name: "item_attribute_detail_include", path: "/api/v3/item-attribute/#{item_attribute_id}?include=items", kind: :detail, include: true },
        { name: "item_fling_effect_list", path: "/api/v3/item-fling-effect?limit=20", kind: :list, include: false },
        { name: "item_fling_effect_detail", path: "/api/v3/item-fling-effect/#{item_fling_effect_id}", kind: :detail, include: false },
        { name: "item_fling_effect_list_include", path: "/api/v3/item-fling-effect?limit=20&include=items", kind: :list, include: true },
        { name: "item_fling_effect_detail_include", path: "/api/v3/item-fling-effect/#{item_fling_effect_id}?include=items", kind: :detail, include: true },
        { name: "language_list", path: "/api/v3/language?limit=20", kind: :list, include: false },
        { name: "language_detail", path: "/api/v3/language/#{language_id}", kind: :detail, include: false },
        { name: "location_list", path: "/api/v3/location?limit=20", kind: :list, include: false },
        { name: "location_detail", path: "/api/v3/location/#{location_id}", kind: :detail, include: false },
        { name: "location_list_include", path: "/api/v3/location?limit=20&include=region", kind: :list, include: true },
        { name: "location_detail_include", path: "/api/v3/location/#{location_id}?include=region", kind: :detail, include: true },
        { name: "location_area_list", path: "/api/v3/location-area?limit=20", kind: :list, include: false },
        { name: "location_area_detail", path: "/api/v3/location-area/#{location_area_id}", kind: :detail, include: false },
        { name: "location_area_list_include", path: "/api/v3/location-area?limit=20&include=location", kind: :list, include: true },
        { name: "location_area_detail_include", path: "/api/v3/location-area/#{location_area_id}?include=location", kind: :detail, include: true },
        { name: "machine_list", path: "/api/v3/machine?limit=20", kind: :list, include: false },
        { name: "machine_detail", path: "/api/v3/machine/#{machine_id}", kind: :detail, include: false },
        { name: "machine_list_include", path: "/api/v3/machine?limit=20&include=item", kind: :list, include: true },
        { name: "machine_detail_include", path: "/api/v3/machine/#{machine_id}?include=item", kind: :detail, include: true },
        { name: "move_ailment_list", path: "/api/v3/move-ailment?limit=20", kind: :list, include: false },
        { name: "move_ailment_detail", path: "/api/v3/move-ailment/#{move_ailment_id}", kind: :detail, include: false },
        { name: "move_battle_style_list", path: "/api/v3/move-battle-style?limit=20", kind: :list, include: false },
        { name: "move_battle_style_detail", path: "/api/v3/move-battle-style/#{move_battle_style_id}", kind: :detail, include: false },
        { name: "move_category_list", path: "/api/v3/move-category?limit=20", kind: :list, include: false },
        { name: "move_category_detail", path: "/api/v3/move-category/#{move_category_id}", kind: :detail, include: false },
        { name: "move_damage_class_list", path: "/api/v3/move-damage-class?limit=20", kind: :list, include: false },
        { name: "move_damage_class_detail", path: "/api/v3/move-damage-class/#{move_damage_class_id}", kind: :detail, include: false },
        { name: "move_learn_method_list", path: "/api/v3/move-learn-method?limit=20", kind: :list, include: false },
        { name: "move_learn_method_detail", path: "/api/v3/move-learn-method/#{move_learn_method_id}", kind: :detail, include: false },
        { name: "move_target_list", path: "/api/v3/move-target?limit=20", kind: :list, include: false },
        { name: "move_target_detail", path: "/api/v3/move-target/#{move_target_id}", kind: :detail, include: false },
        { name: "characteristic_list", path: "/api/v3/characteristic?limit=20", kind: :list, include: false },
        { name: "characteristic_detail", path: "/api/v3/characteristic/#{characteristic_id}", kind: :detail, include: false },
        { name: "stat_list", path: "/api/v3/stat?limit=20", kind: :list, include: false },
        { name: "stat_detail", path: "/api/v3/stat/#{stat_id}", kind: :detail, include: false },
        { name: "super_contest_effect_list", path: "/api/v3/super-contest-effect?limit=20", kind: :list, include: false },
        { name: "super_contest_effect_detail", path: "/api/v3/super-contest-effect/#{super_contest_effect_id}", kind: :detail, include: false },
        { name: "pal_park_area_list", path: "/api/v3/pal-park-area?limit=20", kind: :list, include: false },
        { name: "pal_park_area_detail", path: "/api/v3/pal-park-area/#{pal_park_area_id}", kind: :detail, include: false },
        { name: "pokeathlon_stat_list", path: "/api/v3/pokeathlon-stat?limit=20", kind: :list, include: false },
        { name: "pokeathlon_stat_detail", path: "/api/v3/pokeathlon-stat/#{pokeathlon_stat_id}", kind: :detail, include: false },
        { name: "pokedex_list", path: "/api/v3/pokedex?limit=20", kind: :list, include: false },
        { name: "pokedex_detail", path: "/api/v3/pokedex/#{pokedex_id}", kind: :detail, include: false },
        { name: "pokemon_color_list", path: "/api/v3/pokemon-color?limit=20", kind: :list, include: false },
        { name: "pokemon_color_detail", path: "/api/v3/pokemon-color/#{pokemon_color_id}", kind: :detail, include: false },
        { name: "pokemon_form_list", path: "/api/v3/pokemon-form?limit=20", kind: :list, include: false },
        { name: "pokemon_form_detail", path: "/api/v3/pokemon-form/#{pokemon_form_id}", kind: :detail, include: false },
        { name: "pokemon_habitat_list", path: "/api/v3/pokemon-habitat?limit=20", kind: :list, include: false },
        { name: "pokemon_habitat_detail", path: "/api/v3/pokemon-habitat/#{pokemon_habitat_id}", kind: :detail, include: false },
        { name: "pokemon_shape_list", path: "/api/v3/pokemon-shape?limit=20", kind: :list, include: false },
        { name: "pokemon_shape_detail", path: "/api/v3/pokemon-shape/#{pokemon_shape_id}", kind: :detail, include: false }
      ]

      budgets = {
        [:list, false] => {
          query_max: ENV.fetch("V3_BUDGET_LIST_QUERY_MAX", "8").to_i,
          response_ms_max: ENV.fetch("V3_BUDGET_LIST_RESPONSE_MS_MAX", "150").to_f
        },
        [:detail, false] => {
          query_max: ENV.fetch("V3_BUDGET_DETAIL_QUERY_MAX", "6").to_i,
          response_ms_max: ENV.fetch("V3_BUDGET_DETAIL_RESPONSE_MS_MAX", "120").to_f
        },
        [:list, true] => {
          query_max: ENV.fetch("V3_BUDGET_LIST_INCLUDE_QUERY_MAX", "12").to_i,
          response_ms_max: ENV.fetch("V3_BUDGET_LIST_INCLUDE_RESPONSE_MS_MAX", "220").to_f
        },
        [:detail, true] => {
          query_max: ENV.fetch("V3_BUDGET_DETAIL_INCLUDE_QUERY_MAX", "10").to_i,
          response_ms_max: ENV.fetch("V3_BUDGET_DETAIL_INCLUDE_RESPONSE_MS_MAX", "180").to_f
        }
      }

      session = ActionDispatch::Integration::Session.new(Rails.application)
      session.host! ENV.fetch("V3_BUDGET_HOST", "localhost")
      checker = Pokeapi::Contract::V3BudgetChecker.new(session: session, scenarios: scenarios, budgets: budgets)
      result = checker.run

      case output_format
      when "json"
        puts JSON.pretty_generate(result)
      when "text"
        puts "Task: #{result[:task]}"
        puts "V3 budget check: #{result[:passed] ? 'passed' : 'failed'}"
        puts "Scenarios: #{result[:scenarios].size}"
        puts ""
        result[:scenarios].each do |scenario_result|
          status = scenario_result[:passed] ? "PASS" : "FAIL"
          puts "[#{status}] #{scenario_result[:name]} #{scenario_result[:path]}"
          puts "  status=#{scenario_result[:status]} query_count=#{scenario_result[:query_count]} response_ms=#{scenario_result[:response_time_ms]}"
          unless scenario_result[:passed]
            puts "  breaches: #{scenario_result[:breaches].join(', ')}"
          end
        end
      else
        raise "Unsupported OUTPUT_FORMAT=#{output_format.inspect} (expected: text or json)"
      end

      raise "V3 budget check failed" unless result[:passed]
    end
  end
end
