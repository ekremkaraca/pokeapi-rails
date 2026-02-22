module Api
  module V2
    class MoveController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeMove
      RESOURCE_URL_HELPER = :api_v2_move_url

      private

      def detail_payload(move)
        {
          accuracy: move.accuracy,
          contest_combos: contest_combos_payload(move),
          contest_effect: contest_effect_payload(move),
          contest_type: contest_type_payload(move),
          damage_class: damage_class_payload(move),
          effect_chance: move.effect_chance,
          effect_changes: effect_changes_payload(move),
          effect_entries: effect_entries_payload(move),
          flavor_text_entries: flavor_text_entries_payload(move),
          generation: generation_payload(move),
          id: move.id,
          learned_by_pokemon: learned_by_pokemon_payload(move),
          machines: machines_payload(move),
          meta: meta_payload(move),
          name: move.name,
          names: names_payload(move),
          past_values: past_values_payload(move),
          power: move.power,
          pp: move.pp,
          priority: move.priority,
          stat_changes: stat_changes_payload(move),
          super_contest_effect: super_contest_effect_payload(move),
          target: target_payload(move),
          type: type_payload(move)
        }
      end

      def contest_combos_payload(move)
        normal_rows = move.contest_combos_as_first
        normal_reverse_rows = move.contest_combos_as_second
        super_rows = move.super_contest_combos_as_first
        super_reverse_rows = move.super_contest_combos_as_second

        {
          normal: {
            use_before: combo_moves(normal_rows, :second_move_id),
            use_after: combo_moves(normal_reverse_rows, :first_move_id)
          },
          super: {
            use_before: combo_moves(super_rows, :second_move_id),
            use_after: combo_moves(super_reverse_rows, :first_move_id)
          }
        }
      end

      def contest_effect_payload(move)
        contest_effect = move.contest_effect
        return nil unless contest_effect

        { url: "#{api_v2_contest_effect_url(contest_effect).sub(%r{/+\z}, '')}/" }
      end

      def contest_type_payload(move)
        contest_type = move.contest_type
        return nil unless contest_type

        resource_payload(contest_type, :api_v2_contest_type_url)
      end

      def damage_class_payload(move)
        damage_class = move.damage_class
        return nil unless damage_class

        resource_payload(damage_class, :api_v2_move_damage_class_url)
      end

      def generation_payload(move)
        generation = move.generation
        return nil unless generation

        resource_payload(generation, :api_v2_generation_url)
      end

      def target_payload(move)
        target = move.target
        return nil unless target

        resource_payload(target, :api_v2_move_target_url)
      end

      def type_payload(move)
        type = move.type
        return nil unless type

        resource_payload(type, :api_v2_type_url)
      end

      def super_contest_effect_payload(move)
        effect = move.super_contest_effect
        return nil unless effect

        { url: "#{api_v2_super_contest_effect_url(effect).sub(%r{/+\z}, '')}/" }
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
        prose_rows = PokeMoveEffectChangelogProse.where(move_effect_changelog_id: changelog_rows.map(&:id))
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

      def learned_by_pokemon_payload(move)
        move.pokemon_moves.includes(:pokemon).map(&:pokemon).compact.uniq.sort_by(&:id).map do |pokemon|
          resource_payload(pokemon, :api_v2_pokemon_url)
        end
      end

      def machines_payload(move)
        machines = move.machines.order(:id)
        version_groups_by_id = records_by_id(PokeVersionGroup, machines.map(&:version_group_id))

        machines.filter_map do |machine|
          version_group = version_groups_by_id[machine.version_group_id]
          next unless version_group

          {
            machine: { url: "#{api_v2_machine_url(machine).sub(%r{/+\z}, '')}/" },
            version_group: resource_payload(version_group, :api_v2_version_group_url)
          }
        end
      end

      def meta_payload(move)
        row = move.move_meta
        return nil unless row

        {
          ailment: ailment_payload(row),
          ailment_chance: row.ailment_chance,
          category: meta_category_payload(row),
          crit_rate: row.crit_rate,
          drain: row.drain,
          flinch_chance: row.flinch_chance,
          healing: row.healing,
          max_hits: row.max_hits,
          max_turns: row.max_turns,
          min_hits: row.min_hits,
          min_turns: row.min_turns,
          stat_chance: row.stat_chance
        }
      end

      def meta_category_payload(move_meta)
        category = move_meta.meta_category
        return nil unless category

        resource_payload(category, :api_v2_move_category_url)
      end

      def ailment_payload(move_meta)
        ailment = move_meta.meta_ailment
        return nil unless ailment

        resource_payload(ailment, :api_v2_move_ailment_url)
      end

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

      def stat_changes_payload(move)
        rows = move.move_meta_stat_changes.includes(:stat)

        rows.filter_map do |row|
          stat = row.stat
          next unless stat

          {
            change: row.change,
            stat: resource_payload(stat, :api_v2_stat_url)
          }
        end
      end

      def combo_moves(rows, key)
        move_ids = rows.map { |row| row.public_send(key) }.uniq
        moves = PokeMove.where(id: move_ids).order(:id).map do |move|
          resource_payload(move, :api_v2_move_url)
        end
        moves.empty? ? nil : moves
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

      def resource_payload(record, route_helper)
        {
          name: record.name,
          url: "#{public_send(route_helper, record).sub(%r{/+\z}, '')}/"
        }
      end

      def records_by_id(model_class, ids, allow_zero: false)
        normalized_ids = ids.filter_map { |id| normalized_id(id, allow_zero: allow_zero) }.uniq
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

      def normalized_id(value, allow_zero: false)
        stripped = value.to_s.strip
        return nil if stripped.empty?

        integer_id = stripped.to_i
        return integer_id if allow_zero && integer_id >= 0

        integer_id.positive? ? integer_id : nil
      end
    end
  end
end
