module Pokeapi
  module Importers
    class ContestEffectImporter < BaseCsvImporter
      MODEL_CLASS = PokeContestEffect
      CSV_PATH = "data/v2/csv/contest_effects.csv"
      BATCH_SIZE = 200

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          appeal: required_value(csv_row, :appeal).to_i,
          jam: required_value(csv_row, :jam).to_i
        )
      end
    end
  end
end
