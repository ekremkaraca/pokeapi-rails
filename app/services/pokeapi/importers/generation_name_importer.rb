module Pokeapi
  module Importers
    class GenerationNameImporter < BaseCsvImporter
      MODEL_CLASS = PokeGenerationName
      CSV_PATH = "data/v2/csv/generation_names.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          generation_id: required_value(csv_row, :generation_id).to_i,
          local_language_id: required_value(csv_row, :local_language_id).to_i,
          name: required_value(csv_row, :name)
        )
      end
    end
  end
end
