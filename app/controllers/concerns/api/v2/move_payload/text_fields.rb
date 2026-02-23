module Api
  module V2
    module MovePayload
      module TextFields
        extend ActiveSupport::Concern

        private

        def names_payload(move)
          rows = move.move_names
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

        def effect_entries_payload(move)
          rows = move.move_effect_proses
          languages_by_id = records_by_id(PokeLanguage, rows.map(&:local_language_id))

          rows.filter_map do |row|
            language = languages_by_id[row.local_language_id]
            next unless language

            {
              effect: normalize_prose(replace_effect_tokens(row.effect, row_effect_chance: nil)),
              short_effect: normalize_prose(replace_effect_tokens(row.short_effect, row_effect_chance: nil)),
              language: resource_payload(language, :api_v2_language_url)
            }
          end
        end

        def effect_changes_payload(move)
          changelog_rows = move.move_effect_changelogs
          version_groups_by_id = records_by_id(PokeVersionGroup, changelog_rows.map(&:changed_in_version_group_id))
          prose_rows = changelog_rows.flat_map(&:proses)
          prose_by_changelog_id = prose_rows.group_by(&:move_effect_changelog_id)
          languages_by_id = records_by_id(PokeLanguage, prose_rows.map(&:local_language_id))

          changelog_rows.filter_map do |change_row|
            version_group = version_groups_by_id[change_row.changed_in_version_group_id]
            next unless version_group

            entries = prose_by_changelog_id.fetch(change_row.id, []).filter_map do |row|
              language = languages_by_id[row.local_language_id]
              next unless language

              {
                effect: normalize_prose(row.effect),
                language: resource_payload(language, :api_v2_language_url)
              }
            end

            {
              effect_entries: entries,
              version_group: resource_payload(version_group, :api_v2_version_group_url)
            }
          end
        end

        def flavor_text_entries_payload(move)
          rows = move.move_flavor_texts
          languages_by_id = records_by_id(PokeLanguage, rows.map(&:language_id))
          version_groups_by_id = records_by_id(PokeVersionGroup, rows.map(&:version_group_id))

          rows.filter_map do |row|
            language = languages_by_id[row.language_id]
            version_group = version_groups_by_id[row.version_group_id]
            next unless language && version_group

            {
              flavor_text: row.flavor_text,
              language: resource_payload(language, :api_v2_language_url),
              version_group: resource_payload(version_group, :api_v2_version_group_url)
            }
          end
        end

        def past_values_payload(move)
          rows = move.move_changelogs
          version_groups_by_id = records_by_id(PokeVersionGroup, rows.map(&:changed_in_version_group_id))
          type_ids = rows.map { |row| normalized_id(row.type_id) }.compact
          types_by_id = records_by_id(PokeType, type_ids)

          rows.filter_map do |row|
            version_group = version_groups_by_id[row.changed_in_version_group_id]
            next unless version_group

            type_id = normalized_id(row.type_id)
            type_record = type_id ? types_by_id[type_id] : nil

            {
              accuracy: row.accuracy,
              effect_chance: row.effect_chance,
              power: row.power,
              pp: row.pp,
              type: type_record ? resource_payload(type_record, :api_v2_type_url) : nil,
              version_group: resource_payload(version_group, :api_v2_version_group_url)
            }
          end
        end

        def replace_effect_tokens(value, row_effect_chance:)
          return value if value.nil?
          return value unless row_effect_chance

          value.gsub("$effect_chance", row_effect_chance.to_s).gsub("$probabilité_d'effet", row_effect_chance.to_s)
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
end
