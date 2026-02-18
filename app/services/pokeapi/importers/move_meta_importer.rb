module Pokeapi
  module Importers
    class MoveMetaImporter < BaseCsvImporter
      MODEL_CLASS = PokeMoveMeta
      CSV_PATH = "data/v2/csv/move_meta.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          move_id: required_value(csv_row, :move_id).to_i,
          meta_category_id: optional_integer(csv_row, :meta_category_id),
          meta_ailment_id: optional_integer(csv_row, :meta_ailment_id),
          min_hits: optional_integer(csv_row, :min_hits),
          max_hits: optional_integer(csv_row, :max_hits),
          min_turns: optional_integer(csv_row, :min_turns),
          max_turns: optional_integer(csv_row, :max_turns),
          drain: optional_integer(csv_row, :drain),
          healing: optional_integer(csv_row, :healing),
          crit_rate: optional_integer(csv_row, :crit_rate),
          ailment_chance: optional_integer(csv_row, :ailment_chance),
          flinch_chance: optional_integer(csv_row, :flinch_chance),
          stat_chance: optional_integer(csv_row, :stat_chance)
        )
      end

      def optional_integer(row, key)
        value = optional_value(row, key)
        return nil if value.nil? || value.to_s.strip.empty?

        value.to_i
      end
    end
  end
end
