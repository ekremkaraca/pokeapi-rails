module Pokeapi
  module Importers
    class LocationImporter < BaseCsvImporter
      MODEL_CLASS = PokeLocation
      CSV_PATH = "data/v2/csv/locations.csv"
      BATCH_SIZE = 500
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          region_id: optional_value(csv_row, :region_id)&.to_i
        )
      end
    end
  end
end
