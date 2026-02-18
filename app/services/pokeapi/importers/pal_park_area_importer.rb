module Pokeapi
  module Importers
    class PalParkAreaImporter < BaseCsvImporter
      MODEL_CLASS = PokePalParkArea
      CSV_PATH = "data/v2/csv/pal_park_areas.csv"
      BATCH_SIZE = 100
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier)
        )
      end
    end
  end
end
