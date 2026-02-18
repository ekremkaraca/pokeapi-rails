module Pokeapi
  module Importers
    class ItemImporter < BaseCsvImporter
      MODEL_CLASS = PokeItem
      CSV_PATH = "data/v2/csv/items.csv"
      BATCH_SIZE = 1_000
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          category_id: optional_value(csv_row, :category_id)&.to_i,
          cost: optional_value(csv_row, :cost)&.to_i,
          fling_power: optional_value(csv_row, :fling_power)&.to_i,
          fling_effect_id: optional_value(csv_row, :fling_effect_id)&.to_i
        )
      end
    end
  end
end
