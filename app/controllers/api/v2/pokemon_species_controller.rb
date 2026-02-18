module Api
  module V2
    class PokemonSpeciesController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokePokemonSpecies
      RESOURCE_URL_HELPER = :api_v2_pokemon_species_url

      private

      def detail_payload(species)
        {
          base_happiness: species.base_happiness,
          capture_rate: species.capture_rate,
          color: color_payload(species.color_id),
          egg_groups: egg_groups_payload(species.id),
          evolution_chain: evolution_chain_payload(species.evolution_chain_id),
          evolves_from_species: evolves_from_species_payload(species.evolves_from_species_id),
          flavor_text_entries: flavor_text_entries_payload(species.id),
          form_descriptions: form_descriptions_payload(species.id),
          forms_switchable: species.forms_switchable,
          gender_rate: species.gender_rate,
          genera: genera_payload(species.id),
          generation: generation_payload(species.generation_id),
          growth_rate: growth_rate_payload(species.growth_rate_id),
          habitat: habitat_payload(species.habitat_id),
          has_gender_differences: species.has_gender_differences,
          hatch_counter: species.hatch_counter,
          id: species.id,
          is_baby: species.is_baby,
          is_legendary: species.is_legendary,
          is_mythical: species.is_mythical,
          name: species.name,
          names: names_payload(species.id),
          order: species.sort_order,
          pal_park_encounters: pal_park_encounters_payload(species.id),
          pokedex_numbers: pokedex_numbers_payload(species.id),
          shape: shape_payload(species.shape_id),
          varieties: varieties_payload(species.id)
        }
      end

      def color_payload(color_id)
        color = PokePokemonColor.find_by(id: color_id)
        return nil unless color

        resource_payload(color, :api_v2_pokemon_color_url)
      end

      def generation_payload(generation_id)
        generation = PokeGeneration.find_by(id: generation_id)
        return nil unless generation

        resource_payload(generation, :api_v2_generation_url)
      end

      def growth_rate_payload(growth_rate_id)
        growth_rate = PokeGrowthRate.find_by(id: growth_rate_id)
        return nil unless growth_rate

        resource_payload(growth_rate, :api_v2_growth_rate_url)
      end

      def habitat_payload(habitat_id)
        habitat = PokePokemonHabitat.find_by(id: habitat_id)
        return nil unless habitat

        resource_payload(habitat, :api_v2_pokemon_habitat_url)
      end

      def shape_payload(shape_id)
        shape = PokePokemonShape.find_by(id: shape_id)
        return nil unless shape

        resource_payload(shape, :api_v2_pokemon_shape_url)
      end

      def evolution_chain_payload(evolution_chain_id)
        chain = PokeEvolutionChain.find_by(id: evolution_chain_id)
        return nil unless chain

        { url: "#{api_v2_evolution_chain_url(chain).sub(%r{/+\z}, '')}/" }
      end

      def evolves_from_species_payload(evolves_from_species_id)
        parent = PokePokemonSpecies.find_by(id: evolves_from_species_id)
        return nil unless parent

        resource_payload(parent, :api_v2_pokemon_species_url)
      end

      def egg_groups_payload(species_id)
        egg_group_ids = PokePokemonEggGroup.where(species_id: species_id).pluck(:egg_group_id).uniq
        PokeEggGroup.where(id: egg_group_ids).order(:id).map do |egg_group|
          resource_payload(egg_group, :api_v2_egg_group_url)
        end
      end

      def names_payload(species_id)
        rows = PokePokemonSpeciesName.where(pokemon_species_id: species_id)
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

      def genera_payload(species_id)
        rows = PokePokemonSpeciesName.where(pokemon_species_id: species_id)
        languages_by_id = records_by_id(PokeLanguage, rows.map(&:local_language_id))

        rows.filter_map do |row|
          next if row.genus.to_s.strip.empty?

          language = languages_by_id[row.local_language_id]
          next unless language

          {
            genus: row.genus,
            language: resource_payload(language, :api_v2_language_url)
          }
        end
      end

      def flavor_text_entries_payload(species_id)
        rows = PokePokemonSpeciesFlavorText.where(species_id: species_id)
        languages_by_id = records_by_id(PokeLanguage, rows.map(&:language_id))
        versions_by_id = records_by_id(PokeVersion, rows.map(&:version_id))

        rows.filter_map do |row|
          language = languages_by_id[row.language_id]
          version = versions_by_id[row.version_id]
          next unless language && version

          {
            flavor_text: normalize_text(row.flavor_text),
            language: resource_payload(language, :api_v2_language_url),
            version: resource_payload(version, :api_v2_version_url)
          }
        end
      end

      def form_descriptions_payload(species_id)
        rows = PokePokemonSpeciesProse.where(pokemon_species_id: species_id)
        languages_by_id = records_by_id(PokeLanguage, rows.map(&:local_language_id))

        rows.filter_map do |row|
          next if row.form_description.to_s.strip.empty?

          language = languages_by_id[row.local_language_id]
          next unless language

          {
            description: normalize_text(row.form_description),
            language: resource_payload(language, :api_v2_language_url)
          }
        end
      end

      def pal_park_encounters_payload(species_id)
        rows = PokePalPark.where(species_id: species_id)
        areas_by_id = records_by_id(PokePalParkArea, rows.map(&:area_id))

        rows.filter_map do |row|
          area = areas_by_id[row.area_id]
          next unless area

          {
            area: resource_payload(area, :api_v2_pal_park_area_url),
            base_score: row.base_score,
            rate: row.rate
          }
        end
      end

      def pokedex_numbers_payload(species_id)
        rows = PokePokemonDexNumber.where(species_id: species_id)
        pokedexes_by_id = records_by_id(PokePokedex, rows.map(&:pokedex_id))

        rows.filter_map do |row|
          pokedex = pokedexes_by_id[row.pokedex_id]
          next unless pokedex

          {
            entry_number: row.pokedex_number,
            pokedex: resource_payload(pokedex, :api_v2_pokedex_url)
          }
        end
      end

      def varieties_payload(species_id)
        Pokemon.where(species_id: species_id).order(:id).map do |pokemon|
          {
            is_default: pokemon.is_default,
            pokemon: resource_payload(pokemon, :api_v2_pokemon_url)
          }
        end
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

      def normalize_text(value)
        return value if value.nil?

        value
          .gsub(/\[([^\]]+)\]\{[^}]+\}/, '\1')
          .gsub(/\[\]\{[^}]+\}/, "")
      end
    end
  end
end
