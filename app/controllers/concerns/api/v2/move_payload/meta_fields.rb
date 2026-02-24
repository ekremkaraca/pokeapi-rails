module Api
  module V2
    module MovePayload
      module MetaFields
        extend ActiveSupport::Concern

        private

        def meta_payload(move)
          row = move.move_meta
          return nil unless row
          meta_ailment_by_id = records_by_id(PokeMoveAilment, [ row.meta_ailment_id ], allow_zero: true)
          meta_category_by_id = records_by_id(PokeMoveMetaCategory, [ row.meta_category_id ], allow_zero: true)

          {
            ailment: ailment_payload(row, meta_ailment_by_id),
            ailment_chance: row.ailment_chance,
            category: meta_category_payload(row, meta_category_by_id),
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

        def stat_changes_payload(move)
          rows = move.move_meta_stat_changes
          stats_by_id = records_by_id(PokeStat, rows.map(&:stat_id))

          rows.filter_map do |row|
            stat = stats_by_id[row.stat_id]
            next unless stat

            {
              change: row.change,
              stat: resource_payload(stat, :api_v2_stat_url)
            }
          end
        end

        def meta_category_payload(move_meta, meta_category_by_id)
          category = meta_category_by_id[move_meta.meta_category_id]
          return nil unless category

          resource_payload(category, :api_v2_move_category_url)
        end

        def ailment_payload(move_meta, meta_ailment_by_id)
          ailment = meta_ailment_by_id[move_meta.meta_ailment_id]
          return nil unless ailment

          resource_payload(ailment, :api_v2_move_ailment_url)
        end
      end
    end
  end
end
