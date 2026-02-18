module Pokeapi
  module Importers
    class AbilityImporter < BaseCsvImporter
      MODEL_CLASS = Ability
      CSV_PATH = "data/v2/csv/abilities.csv"
      BATCH_SIZE = 1_000
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          generation_id: optional_value(csv_row, :generation_id)&.to_i,
          is_main_series: to_bool(required_value(csv_row, :is_main_series))
        )
      end
    end
  end
end
