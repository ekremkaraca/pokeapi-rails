module Pokeapi
  module Importers
    class LocationNameImporter < BaseCsvImporter
      MODEL_CLASS = PokeLocationName
      CSV_PATH = "data/v2/csv/location_names.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          location_id: required_value(csv_row, :location_id).to_i,
          local_language_id: required_value(csv_row, :local_language_id).to_i,
          name: optional_value(csv_row, :name),
          subtitle: optional_value(csv_row, :subtitle)
        )
      end
    end
  end
end
