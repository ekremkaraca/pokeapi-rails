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

      # item_id => { id, name, url }
      def category_by_item_id(item_ids)
        ids = item_ids.uniq
        return {} if ids.empty?

        PokeItem.where(id: ids).includes(:category).each_with_object({}) do |item, acc|
          category = item.category
          next unless category

          item_id = item.id
          acc[item_id] = {
            id: category.id,
            name: category.name,
            url: canonical_url_for_id(category.id, :api_v3_item_category_url)
          }
        end
      end

      # species_id => { id, name, url }
      def generation_by_species_id(species_ids)
        ids = species_ids.uniq
        return {} if ids.empty?

        PokePokemonSpecies.where(id: ids).includes(:generation).each_with_object({}) do |species, acc|
          generation = species.generation
          next unless generation

          species_id = species.id
          acc[species_id] = {
            id: generation.id,
            name: generation.name,
            url: canonical_url_for_id(generation.id, :api_v3_generation_url)
          }
        end
      end

      # generation_id => { id, name, url }
      def main_region_by_generation_id(generation_ids)
        ids = generation_ids.uniq
        return {} if ids.empty?

        PokeGeneration.where(id: ids).includes(:main_region).each_with_object({}) do |generation, acc|
          region = generation.main_region
          next unless region

          generation_id = generation.id
          acc[generation_id] = {
            id: region.id,
            name: region.name,
            url: canonical_url_for_id(region.id, :api_v3_region_url)
          }
        end
      end

      # version_group_id => { id, name, url }
      def generation_by_version_group_id(version_group_ids)
        ids = version_group_ids.uniq
        return {} if ids.empty?

        PokeVersionGroup.where(id: ids).includes(:generation).each_with_object({}) do |version_group, acc|
          generation = version_group.generation
          next unless generation

          version_group_id = version_group.id
          acc[version_group_id] = {
            id: generation.id,
            name: generation.name,
            url: canonical_url_for_id(generation.id, :api_v3_generation_url)
          }
        end
      end

      # region_id => [{ id, name, url }, ...]
      def generations_by_region_id(region_ids)
        ids = region_ids.uniq
        return {} if ids.empty?

        PokeRegion.where(id: ids).includes(:main_generations).each_with_object({}) do |region, acc|
          rows = region.main_generations.sort_by(&:id)
          next if rows.empty?

          acc[region.id] = rows.map do |generation|
            {
              id: generation.id,
              name: generation.name,
              url: canonical_url_for_id(generation.id, :api_v3_generation_url)
            }
          end
        end
      end

      # version_id => { id, name, url }
      def version_group_by_version_id(version_ids)
        ids = version_ids.uniq
        return {} if ids.empty?

        PokeVersion.where(id: ids).includes(:version_group).each_with_object({}) do |version, acc|
          version_group = version.version_group
          next unless version_group

          version_id = version.id
          acc[version_id] = {
            id: version_group.id,
            name: version_group.name,
            url: canonical_url_for_id(version_group.id, :api_v3_version_group_url)
          }
        end
      end

      # evolution_chain_id => [{ id, name, url }, ...]
      def pokemon_species_by_evolution_chain_id(chain_ids)
        ids = chain_ids.uniq
        return {} if ids.empty?

        PokeEvolutionChain.where(id: ids).includes(:pokemon_species).each_with_object({}) do |chain, acc|
          rows = chain.pokemon_species.sort_by(&:id)
          next if rows.empty?

          acc[chain.id] = rows.map do |species|
            {
              id: species.id,
              name: species.name,
              url: canonical_url_for_id(species.id, :api_v3_pokemon_species_url)
            }
          end
        end
      end

      # berry_firmness_id => [{ id, name, url }, ...]
      def berries_by_firmness_id(firmness_ids)
        ids = firmness_ids.uniq
        return {} if ids.empty?

        PokeBerryFirmness.where(id: ids).includes(:berries).each_with_object({}) do |firmness, acc|
          rows = firmness.berries.sort_by(&:id)
          next if rows.empty?

          acc[firmness.id] = rows.map do |berry|
            {
              id: berry.id,
              name: berry.name,
              url: canonical_url_for_id(berry.id, :api_v3_berry_url)
            }
          end
        end
      end

      # berry_flavor_id => { id, name, url }
      def contest_type_by_berry_flavor_id(flavor_ids)
        ids = flavor_ids.uniq
        return {} if ids.empty?

        rows = PokeBerryFlavor.where(id: ids).includes(:contest_type)

        rows.each_with_object({}) do |flavor, acc|
          contest_type = flavor.contest_type
          next unless contest_type

          acc[flavor.id] = {
            id: contest_type.id,
            name: contest_type.name,
            url: canonical_url_for_id(contest_type.id, :api_v3_contest_type_url)
          }
        end
      end

      # contest_type_id => [{ id, name, url }, ...]
      def berry_flavors_by_contest_type_id(contest_type_ids)
        ids = contest_type_ids.uniq
        return {} if ids.empty?

        PokeContestType.where(id: ids).includes(:berry_flavors).each_with_object({}) do |contest_type, acc|
          rows = contest_type.berry_flavors.sort_by(&:id)
          next if rows.empty?

          acc[contest_type.id] = rows.map do |flavor|
            {
              id: flavor.id,
              name: flavor.name,
              url: canonical_url_for_id(flavor.id, :api_v3_berry_flavor_url)
            }
          end
        end
      end

      # contest_effect_id => [{ id, name, url }, ...]
      def moves_by_contest_effect_id(contest_effect_ids)
        ids = contest_effect_ids.uniq
        return {} if ids.empty?

        PokeContestEffect.where(id: ids).includes(:moves).each_with_object({}) do |effect, acc|
          rows = effect.moves.sort_by(&:id)
          next if rows.empty?

          acc[effect.id] = rows.map do |move|
            {
              id: move.id,
              name: move.name,
              url: canonical_url_for_id(move.id, :api_v3_move_url)
            }
          end
        end
      end

      # item_category_id => { id, name, url }
      def pocket_by_item_category_id(category_ids)
        ids = category_ids.uniq
        return {} if ids.empty?

        PokeItemCategory.where(id: ids).includes(:pocket).each_with_object({}) do |category, acc|
          pocket = category.pocket
          next unless pocket

          category_id = category.id
          acc[category_id] = {
            id: pocket.id,
            name: pocket.name,
            url: canonical_url_for_id(pocket.id, :api_v3_item_pocket_url)
          }
        end
      end

      # item_pocket_id => [{ id, name, url }, ...]
      def item_categories_by_pocket_id(pocket_ids)
        ids = pocket_ids.uniq
        return {} if ids.empty?

        PokeItemPocket.where(id: ids).includes(:item_categories).each_with_object({}) do |pocket, acc|
          rows = pocket.item_categories.sort_by(&:id)
          next if rows.empty?

          acc[pocket.id] = rows.map do |category|
            {
              id: category.id,
              name: category.name,
              url: canonical_url_for_id(category.id, :api_v3_item_category_url)
            }
          end
        end
      end

      # item_attribute_id => [{ id, name, url }, ...]
      def items_by_item_attribute_id(attribute_ids)
        ids = attribute_ids.uniq
        return {} if ids.empty?

        rows = PokeItemFlagMap
          .where(item_flag_id: ids)
          .includes(:item)
          .order(:item_flag_id, :item_id)

        rows.group_by(&:item_flag_id).transform_values do |item_rows|
          item_rows.filter_map do |row|
            item = row.item
            next unless item

            {
              id: item.id,
              name: item.name,
              url: canonical_url_for_id(item.id, :api_v3_item_url)
            }
          end
        end
      end

      # item_fling_effect_id => [{ id, name, url }, ...]
      def items_by_fling_effect_id(effect_ids)
        ids = effect_ids.uniq
        return {} if ids.empty?

        PokeItemFlingEffect.where(id: ids).includes(:items).each_with_object({}) do |effect, acc|
          rows = effect.items.sort_by(&:id)
          next if rows.empty?

          acc[effect.id] = rows.map do |item|
            {
              id: item.id,
              name: item.name,
              url: canonical_url_for_id(item.id, :api_v3_item_url)
            }
          end
        end
      end

      # location_id => { id, name, url }
      def region_by_location_id(location_ids)
        ids = location_ids.uniq
        return {} if ids.empty?

        PokeLocation.where(id: ids).includes(:region).each_with_object({}) do |location, acc|
          region = location.region
          next unless region

          location_id = location.id
          acc[location_id] = {
            id: region.id,
            name: region.name,
            url: canonical_url_for_id(region.id, :api_v3_region_url)
          }
        end
      end

      # location_area_id => { id, name, url }
      def location_by_location_area_id(area_ids)
        ids = area_ids.uniq
        return {} if ids.empty?

        PokeLocationArea.where(id: ids).includes(:location).each_with_object({}) do |area, acc|
          location = area.location
          next unless location

          area_id = area.id
          acc[area_id] = {
            id: location.id,
            name: location.name,
            url: canonical_url_for_id(location.id, :api_v3_location_url)
          }
        end
      end

      # machine_id => { id, name, url }
      def item_by_machine_id(machine_ids)
        ids = machine_ids.uniq
        return {} if ids.empty?

        PokeMachine.where(id: ids).includes(:item).each_with_object({}) do |machine, acc|
          item = machine.item
          next unless item

          machine_id = machine.id
          acc[machine_id] = {
            id: item.id,
            name: item.name,
            url: canonical_url_for_id(item.id, :api_v3_item_url)
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
