module Pokeapi
  module Importers
    class EncounterConditionValueImporter < BaseCsvImporter
      MODEL_CLASS = PokeEncounterConditionValue
      CSV_PATH = "data/v2/csv/encounter_condition_values.csv"
      BATCH_SIZE = 500
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          encounter_condition_id: required_value(csv_row, :encounter_condition_id).to_i,
          name: required_value(csv_row, :name, :identifier),
          is_default: to_bool(required_value(csv_row, :is_default))
        )
      end
    end
  end
end
