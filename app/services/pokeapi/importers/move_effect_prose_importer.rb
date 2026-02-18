module Pokeapi
  module Importers
    class MoveEffectProseImporter < BaseCsvImporter
      MODEL_CLASS = PokeMoveEffectProse
      CSV_PATH = "data/v2/csv/move_effect_prose.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          move_effect_id: required_value(csv_row, :move_effect_id).to_i,
          local_language_id: required_value(csv_row, :local_language_id).to_i,
          short_effect: optional_value(csv_row, :short_effect),
          effect: optional_value(csv_row, :effect)
        )
      end
    end
  end
end
