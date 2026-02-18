module Pokeapi
  module Importers
    class MoveChangelogImporter < BaseCsvImporter
      MODEL_CLASS = PokeMoveChangelog
      CSV_PATH = "data/v2/csv/move_changelog.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          move_id: required_value(csv_row, :move_id).to_i,
          changed_in_version_group_id: required_value(csv_row, :changed_in_version_group_id).to_i,
          type_id: optional_integer(csv_row, :type_id),
          power: optional_integer(csv_row, :power),
          pp: optional_integer(csv_row, :pp),
          accuracy: optional_integer(csv_row, :accuracy),
          priority: optional_integer(csv_row, :priority),
          target_id: optional_integer(csv_row, :target_id),
          effect_id: optional_integer(csv_row, :effect_id),
          effect_chance: optional_integer(csv_row, :effect_chance)
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
