module Pokeapi
  module Importers
    class MoveEffectChangelogProseImporter < BaseCsvImporter
      MODEL_CLASS = PokeMoveEffectChangelogProse
      CSV_PATH = "data/v2/csv/move_effect_changelog_prose.csv"
      BATCH_SIZE = 500

      private

      def normalize_row(csv_row)
        with_timestamps(
          move_effect_changelog_id: required_value(csv_row, :move_effect_changelog_id).to_i,
          local_language_id: required_value(csv_row, :local_language_id).to_i,
          effect: optional_value(csv_row, :effect)
        )
      end
    end
  end
end
