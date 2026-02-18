module Pokeapi
  module Importers
    class EncounterConditionValueMapImporter < BaseCsvImporter
      MODEL_CLASS = PokeEncounterConditionValueMap
      CSV_PATH = "data/v2/csv/encounter_condition_value_map.csv"
      BATCH_SIZE = 5_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          encounter_id: required_value(csv_row, :encounter_id).to_i,
          encounter_condition_value_id: required_value(csv_row, :encounter_condition_value_id).to_i
        )
      end
    end
  end
end
