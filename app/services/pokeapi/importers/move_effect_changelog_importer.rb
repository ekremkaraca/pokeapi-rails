module Pokeapi
  module Importers
    class MoveEffectChangelogImporter < BaseCsvImporter
      MODEL_CLASS = PokeMoveEffectChangelog
      CSV_PATH = "data/v2/csv/move_effect_changelog.csv"
      BATCH_SIZE = 200

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          effect_id: required_value(csv_row, :effect_id).to_i,
          changed_in_version_group_id: required_value(csv_row, :changed_in_version_group_id).to_i
        )
      end
    end
  end
end
