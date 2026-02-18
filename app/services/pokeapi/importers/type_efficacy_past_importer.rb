module Pokeapi
  module Importers
    class TypeEfficacyPastImporter < BaseCsvImporter
      MODEL_CLASS = PokeTypeEfficacyPast
      CSV_PATH = "data/v2/csv/type_efficacy_past.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          damage_type_id: required_value(csv_row, :damage_type_id).to_i,
          target_type_id: required_value(csv_row, :target_type_id).to_i,
          damage_factor: required_value(csv_row, :damage_factor).to_i,
          generation_id: required_value(csv_row, :generation_id).to_i
        )
      end
    end
  end
end
