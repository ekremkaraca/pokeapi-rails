module Pokeapi
  module Importers
    class GenerationImporter < BaseCsvImporter
      MODEL_CLASS = PokeGeneration
      CSV_PATH = "data/v2/csv/generations.csv"
      BATCH_SIZE = 100
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          main_region_id: optional_value(csv_row, :main_region_id)&.to_i
        )
      end
    end
  end
end
