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
          color: color_payload(species),
          egg_groups: egg_groups_payload(species),
          evolution_chain: evolution_chain_payload(species),
          evolves_from_species: evolves_from_species_payload(species),
          flavor_text_entries: flavor_text_entries_payload(species),
          form_descriptions: form_descriptions_payload(species),
          forms_switchable: species.forms_switchable,
          gender_rate: species.gender_rate,
          genera: genera_payload(species),
          generation: generation_payload(species),
          growth_rate: growth_rate_payload(species),
          habitat: habitat_payload(species),
          has_gender_differences: species.has_gender_differences,
          hatch_counter: species.hatch_counter,
          id: species.id,
          is_baby: species.is_baby,
          is_legendary: species.is_legendary,
          is_mythical: species.is_mythical,
          name: species.name,
          names: names_payload(species),
          order: species.sort_order,
          pal_park_encounters: pal_park_encounters_payload(species),
          pokedex_numbers: pokedex_numbers_payload(species),
          shape: shape_payload(species),
          varieties: varieties_payload(species)
        }
      end

      def color_payload(species)
        color = species.color
        return nil unless color

        resource_payload(color, :api_v2_pokemon_color_url)
      end

      def generation_payload(species)
        generation = species.generation
        return nil unless generation

        resource_payload(generation, :api_v2_generation_url)
      end

      def growth_rate_payload(species)
        growth_rate = species.growth_rate
        return nil unless growth_rate

        resource_payload(growth_rate, :api_v2_growth_rate_url)
      end

      def habitat_payload(species)
        habitat = species.habitat
        return nil unless habitat

        resource_payload(habitat, :api_v2_pokemon_habitat_url)
      end

      def shape_payload(species)
        shape = species.shape
        return nil unless shape

        resource_payload(shape, :api_v2_pokemon_shape_url)
      end

      def evolution_chain_payload(species)
        chain = species.evolution_chain
        return nil unless chain

        { url: "#{api_v2_evolution_chain_url(chain).sub(%r{/+\z}, '')}/" }
      end

      def evolves_from_species_payload(species)
        parent = species.evolves_from_species
        return nil unless parent

        resource_payload(parent, :api_v2_pokemon_species_url)
      end

      def egg_groups_payload(species)
        rows = species.pokemon_egg_groups.includes(:egg_group).order(:egg_group_id)

        rows.filter_map do |row|
          egg_group = row.egg_group
          next unless egg_group

          resource_payload(egg_group, :api_v2_egg_group_url)
        end
      end

      def names_payload(species)
        rows = species.pokemon_species_names.includes(:local_language)

        rows.filter_map do |row|
          language = row.local_language
          next unless language

          {
            name: row.name,
            language: resource_payload(language, :api_v2_language_url)
          }
        end
      end

      def genera_payload(species)
        rows = species.pokemon_species_names.includes(:local_language)

        rows.filter_map do |row|
          next if row.genus.to_s.strip.empty?

          language = row.local_language
          next unless language

          {
            genus: row.genus,
            language: resource_payload(language, :api_v2_language_url)
          }
        end
      end

      def flavor_text_entries_payload(species)
        rows = species.pokemon_species_flavor_texts.includes(:language, :version)

        rows.filter_map do |row|
          language = row.language
          version = row.version
          next unless language && version

          {
            flavor_text: normalize_text(row.flavor_text),
            language: resource_payload(language, :api_v2_language_url),
            version: resource_payload(version, :api_v2_version_url)
          }
        end
      end

      def form_descriptions_payload(species)
        rows = species.pokemon_species_proses.includes(:local_language)

        rows.filter_map do |row|
          next if row.form_description.to_s.strip.empty?

          language = row.local_language
          next unless language

          {
            description: normalize_text(row.form_description),
            language: resource_payload(language, :api_v2_language_url)
          }
        end
      end

      def pal_park_encounters_payload(species)
        species.pal_parks.includes(:area).filter_map do |row|
          area = row.area
          next unless area

          {
            area: resource_payload(area, :api_v2_pal_park_area_url),
            base_score: row.base_score,
            rate: row.rate
          }
        end
      end

      def pokedex_numbers_payload(species)
        species.pokemon_dex_numbers.includes(:pokedex).filter_map do |row|
          pokedex = row.pokedex
          next unless pokedex

          {
            entry_number: row.pokedex_number,
            pokedex: resource_payload(pokedex, :api_v2_pokedex_url)
          }
        end
      end

      def varieties_payload(species)
        species.pokemon.order(:id).map do |pokemon|
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

      def normalize_text(value)
        return value if value.nil?

        value
          .gsub(/\[([^\]]+)\]\{[^}]+\}/, '\1')
          .gsub(/\[\]\{[^}]+\}/, "")
      end
    end
  end
end
