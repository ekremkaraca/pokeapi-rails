module Pokeapi
  module Importers
    class MoveMetaStatChangeImporter < BaseCsvImporter
      MODEL_CLASS = PokeMoveMetaStatChange
      CSV_PATH = "data/v2/csv/move_meta_stat_changes.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          move_id: required_value(csv_row, :move_id).to_i,
          stat_id: required_value(csv_row, :stat_id).to_i,
          change: required_value(csv_row, :change).to_i
        )
      end
    end
  end
end
