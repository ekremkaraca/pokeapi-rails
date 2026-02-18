module Pokeapi
  module Importers
    class EncounterImporter < BaseCsvImporter
      MODEL_CLASS = PokeEncounter
      CSV_PATH = "data/v2/csv/encounters.csv"
      BATCH_SIZE = 5_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          version_id: required_value(csv_row, :version_id).to_i,
          location_area_id: required_value(csv_row, :location_area_id).to_i,
          encounter_slot_id: required_value(csv_row, :encounter_slot_id).to_i,
          pokemon_id: required_value(csv_row, :pokemon_id).to_i,
          min_level: required_value(csv_row, :min_level).to_i,
          max_level: required_value(csv_row, :max_level).to_i
        )
      end
    end
  end
end
