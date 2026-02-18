module Pokeapi
  module Importers
    class ContestComboImporter < BaseCsvImporter
      MODEL_CLASS = PokeContestCombo
      CSV_PATH = "data/v2/csv/contest_combos.csv"
      BATCH_SIZE = 500

      private

      def normalize_row(csv_row)
        with_timestamps(
          first_move_id: required_value(csv_row, :first_move_id).to_i,
          second_move_id: required_value(csv_row, :second_move_id).to_i
        )
      end
    end
  end
end
