module Pokeapi
  module Importers
    class ItemFlavorTextImporter < BaseCsvImporter
      MODEL_CLASS = PokeItemFlavorText
      CSV_PATH = "data/v2/csv/item_flavor_text.csv"
      BATCH_SIZE = 5_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          item_id: required_value(csv_row, :item_id).to_i,
          version_group_id: required_value(csv_row, :version_group_id).to_i,
          language_id: required_value(csv_row, :language_id).to_i,
          flavor_text: optional_value(csv_row, :flavor_text)
        )
      end
    end
  end
end
