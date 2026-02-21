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
          effect_changes: effect_changes_for(ability),
          effect_entries: effect_entries_for(ability),
          flavor_text_entries: flavor_text_entries_for(ability),
          generation: generation_payload(ability),
          names: names_for(ability),
          pokemon: pokemon_for(ability)
        }
      end

      def names_for(ability)
        ability.ability_names.includes(:local_language).filter_map do |row|
          language = row.local_language
          next unless language

          {
            name: row.name,
            language: language_payload(language)
          }
        end
      end

      def effect_entries_for(ability)
        ability.ability_proses.includes(:local_language).filter_map do |row|
          language = row.local_language
          next unless language

          {
            effect: normalize_prose(row.effect),
            short_effect: normalize_prose(row.short_effect),
            language: language_payload(language)
          }
        end
      end

      def effect_changes_for(ability)
        changelogs = ability.changelogs.includes(:changed_in_version_group, ability_changelog_proses: :local_language).order(:changed_in_version_group_id, :id)

        changelogs.filter_map do |changelog|
          version_group = changelog.changed_in_version_group
          next unless version_group

          entries = changelog.ability_changelog_proses.filter_map do |row|
            language = row.local_language
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

      def flavor_text_entries_for(ability)
        ability.flavor_texts.includes(:language, :version_group).filter_map do |row|
          language = row.language
          version_group = row.version_group
          next unless language && version_group

          {
            flavor_text: row.flavor_text,
            language: language_payload(language),
            version_group: version_group_payload(version_group)
          }
        end
      end

      def pokemon_for(ability)
        ability.pokemon_abilities.includes(:pokemon).order(:pokemon_id, :slot).filter_map do |row|
          pokemon = row.pokemon
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

      def generation_payload(ability)
        generation = ability.generation
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

      def normalize_prose(value)
        return value if value.nil?

        value
          .gsub(/\[([^\]]+)\]\{[^}]+\}/, '\1')
          .gsub(/\[\]\{[^}]+\}/, "")
      end
    end
  end
end
