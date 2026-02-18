module Pokeapi
  module Importers
    class LocationAreaImporter < BaseCsvImporter
      MODEL_CLASS = PokeLocationArea
      CSV_PATH = "data/v2/csv/location_areas.csv"
      BATCH_SIZE = 500

      private

      def normalize_row(csv_row)
        location_id = required_value(csv_row, :location_id).to_i

        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: build_name(location_id, optional_value(csv_row, :identifier)),
          location_id: location_id,
          game_index: required_value(csv_row, :game_index).to_i
        )
      end

      def build_name(location_id, suffix)
        location_name = PokeLocation.find(location_id).name
        name_suffix = suffix.presence || "area"
        "#{location_name}-#{name_suffix}"
      end
    end
  end
end
