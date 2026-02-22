module Api
  module V2
    module MoveDetailPayload
      extend ActiveSupport::Concern
      include MovePayload::RelationFields
      include MovePayload::TextFields
      include MovePayload::MetaFields

      private

      def detail_payload(move)
        core_fields(move)
          .merge(relation_fields(move))
          .merge(text_fields(move))
          .merge(meta_fields(move))
      end

      def core_fields(move)
        {
          accuracy: move.accuracy,
          effect_chance: move.effect_chance,
          id: move.id,
          name: move.name,
          power: move.power,
          pp: move.pp,
          priority: move.priority,
          contest_combos: contest_combos_payload(move),
          learned_by_pokemon: learned_by_pokemon_payload(move),
          machines: machines_payload(move)
        }
      end

      def relation_fields(move)
        {
          contest_effect: contest_effect_payload(move),
          contest_type: contest_type_payload(move),
          damage_class: damage_class_payload(move),
          generation: generation_payload(move),
          super_contest_effect: super_contest_effect_payload(move),
          target: target_payload(move),
          type: type_payload(move)
        }
      end

      def text_fields(move)
        {
          names: names_payload(move),
          effect_changes: effect_changes_payload(move),
          effect_entries: effect_entries_payload(move),
          flavor_text_entries: flavor_text_entries_payload(move),
          past_values: past_values_payload(move)
        }
      end

      def meta_fields(move)
        {
          meta: meta_payload(move),
          stat_changes: stat_changes_payload(move)
        }
      end

      def combo_moves(rows, key)
        move_ids = rows.map { |row| row.public_send(key) }.uniq
        moves = PokeMove.where(id: move_ids).order(:id).map do |move|
          resource_payload(move, :api_v2_move_url)
        end
        moves.empty? ? nil : moves
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
