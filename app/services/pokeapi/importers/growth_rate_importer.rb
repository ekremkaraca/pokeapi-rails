module Pokeapi
  module Importers
    class GrowthRateImporter < BaseCsvImporter
      MODEL_CLASS = PokeGrowthRate
      CSV_PATH = "data/v2/csv/growth_rates.csv"
      BATCH_SIZE = 100
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          formula: optional_value(csv_row, :formula)
        )
      end
    end
  end
end
