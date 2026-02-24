module Api
  module V2
    class PokemonSpeciesController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokePokemonSpecies
      RESOURCE_URL_HELPER = :api_v2_pokemon_species_url

      def show
        record = find_by_id_or_name!(detail_scope, params[:id])
        return unless stale_resource?(record: record, cache_key: "#{model_class.name.underscore}/show")

        render json: detail_payload(record)
      end

      private

      def model_scope
        PokePokemonSpecies.all
      end

      def detail_scope
        PokePokemonSpecies.preload(
          :color,
          :generation,
          :growth_rate,
          :habitat,
          :shape,
          :evolution_chain,
          :evolves_from_species,
          :pokemon_egg_groups,
          :pokemon_species_names,
          :pokemon_species_flavor_texts,
          :pokemon_species_proses,
          :pal_parks,
          :pokemon_dex_numbers,
          :pokemon
        )
      end

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
        rows = species.pokemon_egg_groups.sort_by(&:egg_group_id)
        egg_groups_by_id = records_by_id(PokeEggGroup, rows.map(&:egg_group_id))

        rows.filter_map do |row|
          egg_group = egg_groups_by_id[row.egg_group_id]
          next unless egg_group

          resource_payload(egg_group, :api_v2_egg_group_url)
        end
      end

      def names_payload(species)
        rows = species_name_rows(species)
        languages_by_id = species_name_languages_by_id(species, rows)

        rows.filter_map do |row|
          language = languages_by_id[row.local_language_id]
          next unless language

          {
            name: row.name,
            language: resource_payload(language, :api_v2_language_url)
          }
        end
      end

      def genera_payload(species)
        rows = species_name_rows(species)
        languages_by_id = species_name_languages_by_id(species, rows)

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

      def species_name_rows(species)
        @species_name_rows ||= {}
        @species_name_rows[species.id] ||= species.pokemon_species_names.to_a
      end

      def species_name_languages_by_id(species, rows)
        @species_name_languages ||= {}
        @species_name_languages[species.id] ||= records_by_id(PokeLanguage, rows.map(&:local_language_id))
      end

      def flavor_text_entries_payload(species)
        rows = species.pokemon_species_flavor_texts
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

      def form_descriptions_payload(species)
        rows = species.pokemon_species_proses
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

      def pal_park_encounters_payload(species)
        rows = species.pal_parks
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

      def pokedex_numbers_payload(species)
        rows = species.pokemon_dex_numbers
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

      def records_by_id(model_class, ids)
        normalized_ids = ids.filter_map { |id| normalized_id(id) }.uniq
        return {} if normalized_ids.empty?

        cache = lookup_cache_for(model_class)
        missing_ids = normalized_ids - cache.keys

        if missing_ids.any?
          loaded = model_class.where(id: missing_ids).index_by(&:id)
          missing_ids.each { |id| cache[id] = loaded[id] }
        end

        normalized_ids.each_with_object({}) do |id, rows|
          record = cache[id]
          rows[id] = record if record
        end
      end

      def lookup_cache_for(model_class)
        @lookup_cache ||= {}
        @lookup_cache[model_class] ||= {}
      end

      def normalized_id(value)
        integer_id = value.to_i
        integer_id.positive? ? integer_id : nil
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
