module Pokeapi
  module Importers
    class TypeNameImporter < BaseCsvImporter
      MODEL_CLASS = PokeTypeName
      CSV_PATH = "data/v2/csv/type_names.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          type_id: required_value(csv_row, :type_id).to_i,
          local_language_id: required_value(csv_row, :local_language_id).to_i,
          name: required_value(csv_row, :name)
        )
      end
    end
  end
end
