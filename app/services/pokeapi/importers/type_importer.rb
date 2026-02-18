module Pokeapi
  module Importers
    class TypeImporter < BaseCsvImporter
      MODEL_CLASS = PokeType
      CSV_PATH = "data/v2/csv/types.csv"
      BATCH_SIZE = 200
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          generation_id: optional_value(csv_row, :generation_id)&.to_i,
          damage_class_id: optional_value(csv_row, :damage_class_id)&.to_i
        )
      end
    end
  end
end
