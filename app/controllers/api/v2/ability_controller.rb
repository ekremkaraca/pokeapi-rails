module Api
  module V2
    class AbilityController < BaseController
      include NameSearchableResource

      MODEL_CLASS = Ability
      RESOURCE_URL_HELPER = :api_v2_ability_url

      private

      def detail_payload(ability)
        {
          id: ability.id,
          name: ability.name,
          is_main_series: ability.is_main_series
        }.merge(detail_extras(ability))
      end

      def detail_extras(ability)
        {
          effect_changes: effect_changes_for(ability.id),
          effect_entries: effect_entries_for(ability.id),
          flavor_text_entries: flavor_text_entries_for(ability.id),
          generation: generation_payload(ability.generation_id),
          names: names_for(ability.id),
          pokemon: pokemon_for(ability.id)
        }
      end

      def names_for(ability_id)
        rows = PokeAbilityName.where(ability_id: ability_id)
        languages_by_id = records_by_id(PokeLanguage, rows.map(&:local_language_id))

        rows.filter_map do |row|
          language = languages_by_id[row.local_language_id]
          next unless language

          {
            name: row.name,
            language: language_payload(language)
          }
        end
      end

      def effect_entries_for(ability_id)
        rows = PokeAbilityProse.where(ability_id: ability_id)
        languages_by_id = records_by_id(PokeLanguage, rows.map(&:local_language_id))

        rows.filter_map do |row|
          language = languages_by_id[row.local_language_id]
          next unless language

          {
            effect: normalize_prose(row.effect),
            short_effect: normalize_prose(row.short_effect),
            language: language_payload(language)
          }
        end
      end

      def effect_changes_for(ability_id)
        changelogs = PokeAbilityChangelog.where(ability_id: ability_id)
        version_groups_by_id = records_by_id(PokeVersionGroup, changelogs.map(&:changed_in_version_group_id))
        prose_rows = PokeAbilityChangelogProse.where(ability_changelog_id: changelogs.map(&:id))
        prose_by_changelog_id = prose_rows.group_by(&:ability_changelog_id)
        languages_by_id = records_by_id(PokeLanguage, prose_rows.map(&:local_language_id))

        changelogs.filter_map do |changelog|
          version_group = version_groups_by_id[changelog.changed_in_version_group_id]
          next unless version_group

          entries = prose_by_changelog_id.fetch(changelog.id, []).filter_map do |row|
            language = languages_by_id[row.local_language_id]
            next unless language

            {
              effect: normalize_prose(row.effect),
              language: language_payload(language)
            }
          end

          {
            effect_entries: entries,
            version_group: version_group_payload(version_group)
          }
        end
      end

      def flavor_text_entries_for(ability_id)
        rows = PokeAbilityFlavorText.where(ability_id: ability_id)
        languages_by_id = records_by_id(PokeLanguage, rows.map(&:language_id))
        version_groups_by_id = records_by_id(PokeVersionGroup, rows.map(&:version_group_id))

        rows.filter_map do |row|
          language = languages_by_id[row.language_id]
          version_group = version_groups_by_id[row.version_group_id]
          next unless language && version_group

          {
            flavor_text: row.flavor_text,
            language: language_payload(language),
            version_group: version_group_payload(version_group)
          }
        end
      end

      def pokemon_for(ability_id)
        rows = PokePokemonAbility.where(ability_id: ability_id).order(:pokemon_id, :slot)
        pokemons_by_id = records_by_id(Pokemon, rows.map(&:pokemon_id))

        rows.filter_map do |row|
          pokemon = pokemons_by_id[row.pokemon_id]
          next unless pokemon

          {
            is_hidden: row.is_hidden,
            slot: row.slot,
            pokemon: {
              name: pokemon.name,
              url: canonical_pokemon_url(pokemon)
            }
          }
        end
      end

      def generation_payload(generation_id)
        generation = PokeGeneration.find_by(id: generation_id)
        return nil unless generation

        {
          name: generation.name,
          url: canonical_generation_url(generation)
        }
      end

      def language_payload(language)
        {
          name: language.name,
          url: canonical_language_url(language)
        }
      end

      def version_group_payload(version_group)
        {
          name: version_group.name,
          url: canonical_version_group_url(version_group)
        }
      end

      def canonical_generation_url(generation)
        "#{api_v2_generation_url(generation).sub(%r{/+\z}, '')}/"
      end

      def canonical_language_url(language)
        "#{api_v2_language_url(language).sub(%r{/+\z}, '')}/"
      end

      def canonical_version_group_url(version_group)
        "#{api_v2_version_group_url(version_group).sub(%r{/+\z}, '')}/"
      end

      def canonical_pokemon_url(pokemon)
        "#{api_v2_pokemon_url(pokemon).sub(%r{/+\z}, '')}/"
      end

      def records_by_id(model_class, ids)
        model_class.where(id: ids.uniq).index_by(&:id)
      end

      def normalize_prose(value)
        return value if value.nil?

        value
          .gsub(/\[([^\]]+)\]\{[^}]+\}/, '\1')
          .gsub(/\[\]\{[^}]+\}/, "")
      end
    end
  end
end
