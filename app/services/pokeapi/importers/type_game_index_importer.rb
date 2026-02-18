module Pokeapi
  module Importers
    class TypeGameIndexImporter < BaseCsvImporter
      MODEL_CLASS = PokeTypeGameIndex
      CSV_PATH = "data/v2/csv/type_game_indices.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          type_id: required_value(csv_row, :type_id).to_i,
          generation_id: required_value(csv_row, :generation_id).to_i,
          game_index: required_value(csv_row, :game_index).to_i
        )
      end
    end
  end
end
