module Pokeapi
  module Importers
    class MoveNameImporter < BaseCsvImporter
      MODEL_CLASS = PokeMoveName
      CSV_PATH = "data/v2/csv/move_names.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          move_id: required_value(csv_row, :move_id).to_i,
          local_language_id: required_value(csv_row, :local_language_id).to_i,
          name: required_value(csv_row, :name)
        )
      end
    end
  end
end
