module Pokeapi
  module Importers
    class ItemNameImporter < BaseCsvImporter
      MODEL_CLASS = PokeItemName
      CSV_PATH = "data/v2/csv/item_names.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          item_id: required_value(csv_row, :item_id).to_i,
          local_language_id: required_value(csv_row, :local_language_id).to_i,
          name: required_value(csv_row, :name)
        )
      end
    end
  end
end
