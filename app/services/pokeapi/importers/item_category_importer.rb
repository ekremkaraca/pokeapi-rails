module Pokeapi
  module Importers
    class ItemCategoryImporter < BaseCsvImporter
      MODEL_CLASS = PokeItemCategory
      CSV_PATH = "data/v2/csv/item_categories.csv"
      BATCH_SIZE = 200
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          pocket_id: optional_value(csv_row, :pocket_id)&.to_i
        )
      end
    end
  end
end
