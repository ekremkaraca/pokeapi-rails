module Pokeapi
  module Importers
    class ItemGameIndexImporter < BaseCsvImporter
      MODEL_CLASS = PokeItemGameIndex
      CSV_PATH = "data/v2/csv/item_game_indices.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          item_id: required_value(csv_row, :item_id).to_i,
          generation_id: required_value(csv_row, :generation_id).to_i,
          game_index: required_value(csv_row, :game_index).to_i
        )
      end
    end
  end
end
