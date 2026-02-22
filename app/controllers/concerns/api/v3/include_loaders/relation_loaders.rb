module Api
  module V3
    module IncludeLoaders
      module RelationLoaders
        extend ActiveSupport::Concern

        private

        # species_id => { id, name, url }
        def generation_by_species_id(species_ids)
          ids = species_ids.uniq
          return {} if ids.empty?

          PokePokemonSpecies.where(id: ids).includes(:generation).each_with_object({}) do |species, acc|
            generation = species.generation
            next unless generation

            acc[species.id] = {
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

            acc[generation.id] = {
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

            acc[version_group.id] = {
              id: generation.id,
              name: generation.name,
              url: canonical_url_for_id(generation.id, :api_v3_generation_url)
            }
          end
        end

        # version_id => { id, name, url }
        def version_group_by_version_id(version_ids)
          ids = version_ids.uniq
          return {} if ids.empty?

          PokeVersion.where(id: ids).includes(:version_group).each_with_object({}) do |version, acc|
            version_group = version.version_group
            next unless version_group

            acc[version.id] = {
              id: version_group.id,
              name: version_group.name,
              url: canonical_url_for_id(version_group.id, :api_v3_version_group_url)
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
      end
    end
  end
end
