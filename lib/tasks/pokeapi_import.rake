namespace :pokeapi do
  namespace :import do
    def import_metrics_for(importer)
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      count = importer.run!
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
      rows_per_second = elapsed.positive? ? (count / elapsed) : 0.0

      {
        count: count,
        elapsed: elapsed,
        rows_per_second: rows_per_second,
        skipped: importer.respond_to?(:last_run_skipped?) && importer.last_run_skipped?
      }
    end

    def format_duration(seconds)
      format("%.2fs", seconds)
    end

    def format_throughput(rows_per_second)
      format("%.1f rows/s", rows_per_second)
    end

    IMPORT_TASKS = [
      { name: :ability, importer: "Pokeapi::Importers::AbilityImporter", label: "ability" },
      { name: :ability_changelog, importer: "Pokeapi::Importers::AbilityChangelogImporter", label: "ability changelog", depends_on: [ :ability, :version_group ] },
      { name: :ability_changelog_prose, importer: "Pokeapi::Importers::AbilityChangelogProseImporter", label: "ability changelog prose", depends_on: [ :ability_changelog, :language ] },
      { name: :ability_flavor_text, importer: "Pokeapi::Importers::AbilityFlavorTextImporter", label: "ability flavor text", depends_on: [ :ability, :version_group, :language ] },
      { name: :ability_name, importer: "Pokeapi::Importers::AbilityNameImporter", label: "ability name", depends_on: [ :ability, :language ] },
      { name: :ability_prose, importer: "Pokeapi::Importers::AbilityProseImporter", label: "ability prose", depends_on: [ :ability, :language ] },
      { name: :berry_firmness, importer: "Pokeapi::Importers::BerryFirmnessImporter", label: "berry firmness" },
      { name: :berry_flavor, importer: "Pokeapi::Importers::BerryFlavorImporter", label: "berry flavor" },
      { name: :characteristic, importer: "Pokeapi::Importers::CharacteristicImporter", label: "characteristic" },
      { name: :contest_effect, importer: "Pokeapi::Importers::ContestEffectImporter", label: "contest effect" },
      { name: :contest_combo, importer: "Pokeapi::Importers::ContestComboImporter", label: "contest combo", depends_on: [ :move ] },
      { name: :contest_type, importer: "Pokeapi::Importers::ContestTypeImporter", label: "contest type" },
      { name: :evolution_chain, importer: "Pokeapi::Importers::EvolutionChainImporter", label: "evolution chain" },
      { name: :evolution_trigger, importer: "Pokeapi::Importers::EvolutionTriggerImporter", label: "evolution trigger" },
      { name: :encounter_condition, importer: "Pokeapi::Importers::EncounterConditionImporter", label: "encounter condition" },
      { name: :encounter_condition_value, importer: "Pokeapi::Importers::EncounterConditionValueImporter", label: "encounter condition value" },
      { name: :encounter_condition_value_map, importer: "Pokeapi::Importers::EncounterConditionValueMapImporter", label: "encounter condition value map", depends_on: [ :encounter_condition_value, :encounter ] },
      { name: :encounter, importer: "Pokeapi::Importers::EncounterImporter", label: "encounter", depends_on: [ :version, :location_area, :pokemon ] },
      { name: :encounter_method, importer: "Pokeapi::Importers::EncounterMethodImporter", label: "encounter method" },
      { name: :encounter_slot, importer: "Pokeapi::Importers::EncounterSlotImporter", label: "encounter slot", depends_on: [ :version_group, :encounter_method ] },
      { name: :egg_group, importer: "Pokeapi::Importers::EggGroupImporter", label: "egg group" },
      { name: :generation, importer: "Pokeapi::Importers::GenerationImporter", label: "generation" },
      { name: :generation_name, importer: "Pokeapi::Importers::GenerationNameImporter", label: "generation name", depends_on: [ :generation, :language ] },
      { name: :gender, importer: "Pokeapi::Importers::GenderImporter", label: "gender" },
      { name: :growth_rate, importer: "Pokeapi::Importers::GrowthRateImporter", label: "growth rate" },
      { name: :item, importer: "Pokeapi::Importers::ItemImporter", label: "item" },
      { name: :berry, importer: "Pokeapi::Importers::BerryImporter", label: "berry", depends_on: [ :item ] },
      { name: :item_attribute, importer: "Pokeapi::Importers::ItemAttributeImporter", label: "item attribute" },
      { name: :item_category, importer: "Pokeapi::Importers::ItemCategoryImporter", label: "item category" },
      { name: :item_flag_map, importer: "Pokeapi::Importers::ItemFlagMapImporter", label: "item flag map", depends_on: [ :item, :item_attribute ] },
      { name: :item_flavor_text, importer: "Pokeapi::Importers::ItemFlavorTextImporter", label: "item flavor text", depends_on: [ :item, :version_group, :language ] },
      { name: :item_fling_effect, importer: "Pokeapi::Importers::ItemFlingEffectImporter", label: "item fling effect" },
      { name: :item_game_index, importer: "Pokeapi::Importers::ItemGameIndexImporter", label: "item game index", depends_on: [ :item, :generation ] },
      { name: :item_name, importer: "Pokeapi::Importers::ItemNameImporter", label: "item name", depends_on: [ :item, :language ] },
      { name: :item_pocket, importer: "Pokeapi::Importers::ItemPocketImporter", label: "item pocket" },
      { name: :item_prose, importer: "Pokeapi::Importers::ItemProseImporter", label: "item prose", depends_on: [ :item, :language ] },
      { name: :language, importer: "Pokeapi::Importers::LanguageImporter", label: "language" },
      { name: :location, importer: "Pokeapi::Importers::LocationImporter", label: "location" },
      { name: :location_game_index, importer: "Pokeapi::Importers::LocationGameIndexImporter", label: "location game index", depends_on: [ :location, :generation ] },
      { name: :location_name, importer: "Pokeapi::Importers::LocationNameImporter", label: "location name", depends_on: [ :location, :language ] },
      { name: :location_area, importer: "Pokeapi::Importers::LocationAreaImporter", label: "location area", depends_on: [ :location ] },
      { name: :machine, importer: "Pokeapi::Importers::MachineImporter", label: "machine" },
      { name: :move, importer: "Pokeapi::Importers::MoveImporter", label: "move" },
      { name: :move_changelog, importer: "Pokeapi::Importers::MoveChangelogImporter", label: "move changelog", depends_on: [ :move, :version_group, :type ] },
      { name: :move_effect_changelog, importer: "Pokeapi::Importers::MoveEffectChangelogImporter", label: "move effect changelog", depends_on: [ :version_group ] },
      { name: :move_effect_changelog_prose, importer: "Pokeapi::Importers::MoveEffectChangelogProseImporter", label: "move effect changelog prose", depends_on: [ :move_effect_changelog, :language ] },
      { name: :move_effect_prose, importer: "Pokeapi::Importers::MoveEffectProseImporter", label: "move effect prose", depends_on: [ :language ] },
      { name: :move_flavor_text, importer: "Pokeapi::Importers::MoveFlavorTextImporter", label: "move flavor text", depends_on: [ :move, :version_group, :language ] },
      { name: :move_ailment, importer: "Pokeapi::Importers::MoveAilmentImporter", label: "move ailment" },
      { name: :move_battle_style, importer: "Pokeapi::Importers::MoveBattleStyleImporter", label: "move battle style" },
      { name: :move_category, importer: "Pokeapi::Importers::MoveCategoryImporter", label: "move category" },
      { name: :move_damage_class, importer: "Pokeapi::Importers::MoveDamageClassImporter", label: "move damage class" },
      { name: :move_learn_method, importer: "Pokeapi::Importers::MoveLearnMethodImporter", label: "move learn method" },
      { name: :move_meta, importer: "Pokeapi::Importers::MoveMetaImporter", label: "move meta", depends_on: [ :move, :move_category, :move_ailment ] },
      { name: :move_meta_stat_change, importer: "Pokeapi::Importers::MoveMetaStatChangeImporter", label: "move meta stat change", depends_on: [ :move, :stat ] },
      { name: :move_name, importer: "Pokeapi::Importers::MoveNameImporter", label: "move name", depends_on: [ :move, :language ] },
      { name: :move_target, importer: "Pokeapi::Importers::MoveTargetImporter", label: "move target" },
      { name: :nature, importer: "Pokeapi::Importers::NatureImporter", label: "nature" },
      { name: :pal_park_area, importer: "Pokeapi::Importers::PalParkAreaImporter", label: "pal park area" },
      { name: :pal_park, importer: "Pokeapi::Importers::PalParkImporter", label: "pal park", depends_on: [ :pokemon_species, :pal_park_area ] },
      { name: :pokedex, importer: "Pokeapi::Importers::PokedexImporter", label: "pokedex" },
      { name: :pokedex_version_group, importer: "Pokeapi::Importers::PokedexVersionGroupImporter", label: "pokedex version group", depends_on: [ :pokedex, :version_group ] },
      { name: :pokemon, importer: "Pokeapi::Importers::PokemonImporter", label: "pokemon" },
      { name: :pokemon_ability, importer: "Pokeapi::Importers::PokemonAbilityImporter", label: "pokemon ability", depends_on: [ :pokemon, :ability ] },
      { name: :pokemon_ability_past, importer: "Pokeapi::Importers::PokemonAbilityPastImporter", label: "pokemon past ability", depends_on: [ :pokemon, :ability, :generation ] },
      { name: :pokemon_game_index, importer: "Pokeapi::Importers::PokemonGameIndexImporter", label: "pokemon game index", depends_on: [ :pokemon, :version ] },
      { name: :pokemon_item, importer: "Pokeapi::Importers::PokemonItemImporter", label: "pokemon item", depends_on: [ :pokemon, :item, :version ] },
      { name: :pokemon_move, importer: "Pokeapi::Importers::PokemonMoveImporter", label: "pokemon move", depends_on: [ :pokemon, :move, :version_group, :move_learn_method ] },
      { name: :pokemon_stat, importer: "Pokeapi::Importers::PokemonStatImporter", label: "pokemon stat", depends_on: [ :pokemon, :stat ] },
      { name: :pokemon_stat_past, importer: "Pokeapi::Importers::PokemonStatPastImporter", label: "pokemon past stat", depends_on: [ :pokemon, :stat, :generation ] },
      { name: :pokemon_type, importer: "Pokeapi::Importers::PokemonTypeImporter", label: "pokemon type", depends_on: [ :pokemon, :type ] },
      { name: :pokemon_type_past, importer: "Pokeapi::Importers::PokemonTypePastImporter", label: "pokemon past type", depends_on: [ :pokemon, :type, :generation ] },
      { name: :pokemon_color, importer: "Pokeapi::Importers::PokemonColorImporter", label: "pokemon color" },
      { name: :pokemon_form, importer: "Pokeapi::Importers::PokemonFormImporter", label: "pokemon form" },
      { name: :pokemon_habitat, importer: "Pokeapi::Importers::PokemonHabitatImporter", label: "pokemon habitat" },
      { name: :pokemon_shape, importer: "Pokeapi::Importers::PokemonShapeImporter", label: "pokemon shape" },
      { name: :pokemon_species, importer: "Pokeapi::Importers::PokemonSpeciesImporter", label: "pokemon species" },
      { name: :pokemon_egg_group, importer: "Pokeapi::Importers::PokemonEggGroupImporter", label: "pokemon egg group", depends_on: [ :pokemon_species, :egg_group ] },
      { name: :pokemon_species_name, importer: "Pokeapi::Importers::PokemonSpeciesNameImporter", label: "pokemon species name", depends_on: [ :pokemon_species, :language ] },
      { name: :pokemon_species_flavor_text, importer: "Pokeapi::Importers::PokemonSpeciesFlavorTextImporter", label: "pokemon species flavor text", depends_on: [ :pokemon_species, :version, :language ] },
      { name: :pokemon_species_prose, importer: "Pokeapi::Importers::PokemonSpeciesProseImporter", label: "pokemon species prose", depends_on: [ :pokemon_species, :language ] },
      { name: :pokemon_dex_number, importer: "Pokeapi::Importers::PokemonDexNumberImporter", label: "pokemon dex number", depends_on: [ :pokemon_species, :pokedex ] },
      { name: :pokeathlon_stat, importer: "Pokeapi::Importers::PokeathlonStatImporter", label: "pokeathlon stat" },
      { name: :region, importer: "Pokeapi::Importers::RegionImporter", label: "region" },
      { name: :stat, importer: "Pokeapi::Importers::StatImporter", label: "stat" },
      { name: :super_contest_effect, importer: "Pokeapi::Importers::SuperContestEffectImporter", label: "super contest effect" },
      { name: :super_contest_combo, importer: "Pokeapi::Importers::SuperContestComboImporter", label: "super contest combo", depends_on: [ :move ] },
      { name: :type, importer: "Pokeapi::Importers::TypeImporter", label: "type" },
      { name: :type_efficacy, importer: "Pokeapi::Importers::TypeEfficacyImporter", label: "type efficacy", depends_on: [ :type ] },
      { name: :type_efficacy_past, importer: "Pokeapi::Importers::TypeEfficacyPastImporter", label: "type efficacy past", depends_on: [ :type, :generation ] },
      { name: :type_game_index, importer: "Pokeapi::Importers::TypeGameIndexImporter", label: "type game index", depends_on: [ :type, :generation ] },
      { name: :type_name, importer: "Pokeapi::Importers::TypeNameImporter", label: "type name", depends_on: [ :type, :language ] },
      { name: :version, importer: "Pokeapi::Importers::VersionImporter", label: "version" },
      { name: :version_group, importer: "Pokeapi::Importers::VersionGroupImporter", label: "version group" },
      { name: :version_group_pokemon_move_method, importer: "Pokeapi::Importers::VersionGroupPokemonMoveMethodImporter", label: "version group pokemon move method", depends_on: [ :version_group, :move_learn_method ] },
      { name: :version_group_region, importer: "Pokeapi::Importers::VersionGroupRegionImporter", label: "version group region", depends_on: [ :version_group, :region ] }
    ].freeze

    def order_import_tasks(entries)
      entries_by_name = entries.index_by { |entry| entry[:name] }
      ordered_entries = []
      visit_state = {}

      entries.each do |entry|
        dependencies = Array(entry[:depends_on])
        missing = dependencies.reject { |name| entries_by_name.key?(name) }
        next if missing.empty?

        raise ArgumentError, "import task #{entry[:name]} depends on missing task(s): #{missing.join(', ')}"
      end

      visit = lambda do |entry|
        name = entry[:name]
        state = visit_state[name]
        return if state == :done
        raise ArgumentError, "cyclic import dependency detected at task: #{name}" if state == :visiting

        visit_state[name] = :visiting

        Array(entry[:depends_on]).each do |dependency_name|
          visit.call(entries_by_name.fetch(dependency_name))
        end

        visit_state[name] = :done
        ordered_entries << entry
      end

      entries.each { |entry| visit.call(entry) }
      ordered_entries
    end

    ORDERED_IMPORT_TASKS = order_import_tasks(IMPORT_TASKS).freeze

    def define_import_task(task_name, importer_class_name, label)
      desc "Import #{label} data from source CSV (POKEAPI_SOURCE_DIR or db/data/v2/csv)"
      task task_name => :environment do
        importer = importer_class_name.constantize.new
        metrics = import_metrics_for(importer)
        if metrics[:skipped]
          puts "Skipped #{label} import (unchanged CSV checksum; #{format_duration(metrics[:elapsed])})"
        else
          puts "Imported #{metrics[:count]} #{label} rows (#{format_duration(metrics[:elapsed])}, #{format_throughput(metrics[:rows_per_second])})"
        end
      end
    end

    IMPORT_TASKS.each do |entry|
      define_import_task(entry[:name], entry[:importer], entry[:label])
    end

    desc "Import all registered resources in dependency-safe order"
    task all: :environment do
      total_rows = 0
      total_elapsed = 0.0

      ORDERED_IMPORT_TASKS.each do |entry|
        importer = entry[:importer].constantize.new
        metrics = import_metrics_for(importer)
        total_rows += metrics[:count]
        total_elapsed += metrics[:elapsed]
        if metrics[:skipped]
          puts "Skipped #{entry[:label]} import (unchanged CSV checksum; #{format_duration(metrics[:elapsed])})"
        else
          puts "Imported #{metrics[:count]} #{entry[:label]} rows (#{format_duration(metrics[:elapsed])}, #{format_throughput(metrics[:rows_per_second])})"
        end
      end

      overall_throughput = total_elapsed.positive? ? (total_rows / total_elapsed) : 0.0
      puts "Imported #{total_rows} total rows across #{ORDERED_IMPORT_TASKS.size} resources (#{format_duration(total_elapsed)}, #{format_throughput(overall_throughput)})"
    end
  end
end
