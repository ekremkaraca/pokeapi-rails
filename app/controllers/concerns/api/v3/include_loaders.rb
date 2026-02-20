module Api
  module V3
    # Shared relation loaders for include expansions.
    # Each loader returns a hash keyed by primary resource id.
    module IncludeLoaders
      MAX_INCLUDED_POKEMON_PER_MOVE = 25

      private

      # pokemon_id => [{ is_hidden, slot, ability: { id, name, url } }, ...]
      def abilities_by_pokemon_id(pokemon_ids)
        ids = pokemon_ids.uniq
        return {} if ids.empty?

        rows = PokePokemonAbility.where(pokemon_id: ids).order(:pokemon_id, :slot, :ability_id)
        abilities_by_id = Ability.where(id: rows.map(&:ability_id).uniq).index_by(&:id)

        rows.group_by(&:pokemon_id).transform_values do |ability_rows|
          ability_rows.filter_map do |row|
            ability = abilities_by_id[row.ability_id]
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

        rows = PokePokemonAbility.where(ability_id: ids).order(:ability_id, :slot, :pokemon_id)
        pokemon_by_id = Pokemon.where(id: rows.map(&:pokemon_id).uniq).index_by(&:id)

        rows.group_by(&:ability_id).transform_values do |pokemon_rows|
          pokemon_rows.filter_map do |row|
            pokemon = pokemon_by_id[row.pokemon_id]
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

        rows = PokePokemonType.where(type_id: ids).order(:type_id, :slot, :pokemon_id)
        pokemon_by_id = Pokemon.where(id: rows.map(&:pokemon_id).uniq).index_by(&:id)

        rows.group_by(&:type_id).transform_values do |pokemon_rows|
          pokemon_rows.filter_map do |row|
            pokemon = pokemon_by_id[row.pokemon_id]
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

      # item_id => { id, name, url }
      def category_by_item_id(item_ids)
        ids = item_ids.uniq
        return {} if ids.empty?

        rows = PokeItem
          .joins("INNER JOIN item_category ON item_category.id = item.category_id")
          .where(id: ids)
          .pluck("item.id", "item_category.id", "item_category.name")

        rows.each_with_object({}) do |(item_id, category_id, category_name), acc|
          acc[item_id] = {
            id: category_id,
            name: category_name,
            url: canonical_url_for_id(category_id, :api_v3_item_category_url)
          }
        end
      end

      # species_id => { id, name, url }
      def generation_by_species_id(species_ids)
        ids = species_ids.uniq
        return {} if ids.empty?

        rows = PokePokemonSpecies
          .joins("INNER JOIN generation ON generation.id = pokemon_species.generation_id")
          .where(id: ids)
          .pluck("pokemon_species.id", "generation.id", "generation.name")

        rows.each_with_object({}) do |(species_id, generation_id, generation_name), acc|
          acc[species_id] = {
            id: generation_id,
            name: generation_name,
            url: canonical_url_for_id(generation_id, :api_v3_generation_url)
          }
        end
      end

      # generation_id => { id, name, url }
      def main_region_by_generation_id(generation_ids)
        ids = generation_ids.uniq
        return {} if ids.empty?

        rows = PokeGeneration
          .joins("INNER JOIN region ON region.id = generation.main_region_id")
          .where(id: ids)
          .pluck("generation.id", "region.id", "region.name")

        rows.each_with_object({}) do |(generation_id, region_id, region_name), acc|
          acc[generation_id] = {
            id: region_id,
            name: region_name,
            url: canonical_url_for_id(region_id, :api_v3_region_url)
          }
        end
      end

      # version_group_id => { id, name, url }
      def generation_by_version_group_id(version_group_ids)
        ids = version_group_ids.uniq
        return {} if ids.empty?

        rows = PokeVersionGroup
          .joins("INNER JOIN generation ON generation.id = version_group.generation_id")
          .where(id: ids)
          .pluck("version_group.id", "generation.id", "generation.name")

        rows.each_with_object({}) do |(version_group_id, generation_id, generation_name), acc|
          acc[version_group_id] = {
            id: generation_id,
            name: generation_name,
            url: canonical_url_for_id(generation_id, :api_v3_generation_url)
          }
        end
      end

      # region_id => [{ id, name, url }, ...]
      def generations_by_region_id(region_ids)
        ids = region_ids.uniq
        return {} if ids.empty?

        rows = PokeGeneration
          .where(main_region_id: ids)
          .order(:main_region_id, :id)
          .pluck(:main_region_id, :id, :name)

        rows.group_by(&:first).transform_values do |generation_rows|
          generation_rows.map do |_region_id, generation_id, generation_name|
            {
              id: generation_id,
              name: generation_name,
              url: canonical_url_for_id(generation_id, :api_v3_generation_url)
            }
          end
        end
      end

      # version_id => { id, name, url }
      def version_group_by_version_id(version_ids)
        ids = version_ids.uniq
        return {} if ids.empty?

        rows = PokeVersion
          .joins("INNER JOIN version_group ON version_group.id = version.version_group_id")
          .where(id: ids)
          .pluck("version.id", "version_group.id", "version_group.name")

        rows.each_with_object({}) do |(version_id, version_group_id, version_group_name), acc|
          acc[version_id] = {
            id: version_group_id,
            name: version_group_name,
            url: canonical_url_for_id(version_group_id, :api_v3_version_group_url)
          }
        end
      end

      # evolution_chain_id => [{ id, name, url }, ...]
      def pokemon_species_by_evolution_chain_id(chain_ids)
        ids = chain_ids.uniq
        return {} if ids.empty?

        rows = PokePokemonSpecies
          .where(evolution_chain_id: ids)
          .order(:evolution_chain_id, :id)
          .pluck(:evolution_chain_id, :id, :name)

        rows.group_by(&:first).transform_values do |species_rows|
          species_rows.map do |_chain_id, species_id, species_name|
            {
              id: species_id,
              name: species_name,
              url: canonical_url_for_id(species_id, :api_v3_pokemon_species_url)
            }
          end
        end
      end

      # berry_firmness_id => [{ id, name, url }, ...]
      def berries_by_firmness_id(firmness_ids)
        ids = firmness_ids.uniq
        return {} if ids.empty?

        rows = PokeBerry
          .where(berry_firmness_id: ids)
          .order(:berry_firmness_id, :id)
          .pluck(:berry_firmness_id, :id, :name)

        rows.group_by(&:first).transform_values do |berry_rows|
          berry_rows.map do |_firmness_id, berry_id, berry_name|
            {
              id: berry_id,
              name: berry_name,
              url: canonical_url_for_id(berry_id, :api_v3_berry_url)
            }
          end
        end
      end

      # berry_flavor_id => { id, name, url }
      def contest_type_by_berry_flavor_id(flavor_ids)
        ids = flavor_ids.uniq
        return {} if ids.empty?

        rows = PokeBerryFlavor
          .joins("INNER JOIN contest_type ON contest_type.id = berry_flavor.contest_type_id")
          .where(id: ids)
          .pluck("berry_flavor.id", "contest_type.id", "contest_type.name")

        rows.each_with_object({}) do |(flavor_id, contest_type_id, contest_type_name), acc|
          acc[flavor_id] = {
            id: contest_type_id,
            name: contest_type_name,
            url: canonical_url_for_id(contest_type_id, :api_v3_contest_type_url)
          }
        end
      end

      # contest_type_id => [{ id, name, url }, ...]
      def berry_flavors_by_contest_type_id(contest_type_ids)
        ids = contest_type_ids.uniq
        return {} if ids.empty?

        rows = PokeBerryFlavor
          .where(contest_type_id: ids)
          .order(:contest_type_id, :id)
          .pluck(:contest_type_id, :id, :name)

        rows.group_by(&:first).transform_values do |flavor_rows|
          flavor_rows.map do |_contest_type_id, flavor_id, flavor_name|
            {
              id: flavor_id,
              name: flavor_name,
              url: canonical_url_for_id(flavor_id, :api_v3_berry_flavor_url)
            }
          end
        end
      end

      # contest_effect_id => [{ id, name, url }, ...]
      def moves_by_contest_effect_id(contest_effect_ids)
        ids = contest_effect_ids.uniq
        return {} if ids.empty?

        rows = PokeMove
          .where(contest_effect_id: ids)
          .order(:contest_effect_id, :id)
          .pluck(:contest_effect_id, :id, :name)

        rows.group_by(&:first).transform_values do |move_rows|
          move_rows.map do |_contest_effect_id, move_id, move_name|
            {
              id: move_id,
              name: move_name,
              url: canonical_url_for_id(move_id, :api_v3_move_url)
            }
          end
        end
      end

      # item_category_id => { id, name, url }
      def pocket_by_item_category_id(category_ids)
        ids = category_ids.uniq
        return {} if ids.empty?

        rows = PokeItemCategory
          .joins("INNER JOIN item_pocket ON item_pocket.id = item_category.pocket_id")
          .where(id: ids)
          .pluck("item_category.id", "item_pocket.id", "item_pocket.name")

        rows.each_with_object({}) do |(category_id, pocket_id, pocket_name), acc|
          acc[category_id] = {
            id: pocket_id,
            name: pocket_name,
            url: canonical_url_for_id(pocket_id, :api_v3_item_pocket_url)
          }
        end
      end

      # item_pocket_id => [{ id, name, url }, ...]
      def item_categories_by_pocket_id(pocket_ids)
        ids = pocket_ids.uniq
        return {} if ids.empty?

        rows = PokeItemCategory
          .where(pocket_id: ids)
          .order(:pocket_id, :id)
          .pluck(:pocket_id, :id, :name)

        rows.group_by(&:first).transform_values do |category_rows|
          category_rows.map do |_pocket_id, category_id, category_name|
            {
              id: category_id,
              name: category_name,
              url: canonical_url_for_id(category_id, :api_v3_item_category_url)
            }
          end
        end
      end

      # item_attribute_id => [{ id, name, url }, ...]
      def items_by_item_attribute_id(attribute_ids)
        ids = attribute_ids.uniq
        return {} if ids.empty?

        rows = PokeItemFlagMap
          .joins("INNER JOIN item ON item.id = item_flag_map.item_id")
          .where(item_flag_id: ids)
          .distinct
          .order("item_flag_map.item_flag_id ASC, item.id ASC")
          .pluck("item_flag_map.item_flag_id", "item.id", "item.name")

        rows.group_by(&:first).transform_values do |item_rows|
          item_rows.map do |_attribute_id, item_id, item_name|
            {
              id: item_id,
              name: item_name,
              url: canonical_url_for_id(item_id, :api_v3_item_url)
            }
          end
        end
      end

      # item_fling_effect_id => [{ id, name, url }, ...]
      def items_by_fling_effect_id(effect_ids)
        ids = effect_ids.uniq
        return {} if ids.empty?

        rows = PokeItem
          .where(fling_effect_id: ids)
          .order(:fling_effect_id, :id)
          .pluck(:fling_effect_id, :id, :name)

        rows.group_by(&:first).transform_values do |item_rows|
          item_rows.map do |_effect_id, item_id, item_name|
            {
              id: item_id,
              name: item_name,
              url: canonical_url_for_id(item_id, :api_v3_item_url)
            }
          end
        end
      end

      # location_id => { id, name, url }
      def region_by_location_id(location_ids)
        ids = location_ids.uniq
        return {} if ids.empty?

        rows = PokeLocation
          .joins("INNER JOIN region ON region.id = location.region_id")
          .where(id: ids)
          .pluck("location.id", "region.id", "region.name")

        rows.each_with_object({}) do |(location_id, region_id, region_name), acc|
          acc[location_id] = {
            id: region_id,
            name: region_name,
            url: canonical_url_for_id(region_id, :api_v3_region_url)
          }
        end
      end

      # location_area_id => { id, name, url }
      def location_by_location_area_id(area_ids)
        ids = area_ids.uniq
        return {} if ids.empty?

        rows = PokeLocationArea
          .joins("INNER JOIN location ON location.id = location_area.location_id")
          .where(id: ids)
          .pluck("location_area.id", "location.id", "location.name")

        rows.each_with_object({}) do |(area_id, location_id, location_name), acc|
          acc[area_id] = {
            id: location_id,
            name: location_name,
            url: canonical_url_for_id(location_id, :api_v3_location_url)
          }
        end
      end

      # machine_id => { id, name, url }
      def item_by_machine_id(machine_ids)
        ids = machine_ids.uniq
        return {} if ids.empty?

        rows = PokeMachine
          .joins("INNER JOIN item ON item.id = machine.item_id")
          .where(id: ids)
          .pluck("machine.id", "item.id", "item.name")

        rows.each_with_object({}) do |(machine_id, item_id, item_name), acc|
          acc[machine_id] = {
            id: item_id,
            name: item_name,
            url: canonical_url_for_id(item_id, :api_v3_item_url)
          }
        end
      end

      # Canonical compact object used for nested resource references.
      def resource_ref(record, route_helper)
        {
          id: record.id,
          name: record.name,
          url: canonical_url_for(record, route_helper)
        }
      end

      # Normalizes URL helper output to the API convention with trailing slash.
      def canonical_url_for(record, route_helper)
        "#{public_send(route_helper, record).sub(%r{/+\z}, '')}/"
      end

      def canonical_url_for_id(id, route_helper)
        "#{public_send(route_helper, id).sub(%r{/+\z}, '')}/"
      end
    end
  end
end
