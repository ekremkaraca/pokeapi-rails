module Pokeapi
  module Importers
    class SuperContestEffectImporter < BaseCsvImporter
      MODEL_CLASS = PokeSuperContestEffect
      CSV_PATH = "data/v2/csv/super_contest_effects.csv"
      BATCH_SIZE = 200

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          appeal: required_value(csv_row, :appeal).to_i
        )
      end
    end
  end
end
