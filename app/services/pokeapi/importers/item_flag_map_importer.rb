module Pokeapi
  module Importers
    class ItemFlagMapImporter < BaseCsvImporter
      MODEL_CLASS = PokeItemFlagMap
      CSV_PATH = "data/v2/csv/item_flag_map.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          item_id: required_value(csv_row, :item_id).to_i,
          item_flag_id: required_value(csv_row, :item_flag_id).to_i
        )
      end
    end
  end
end
