module Pokeapi
  module Importers
    class VersionImporter < BaseCsvImporter
      MODEL_CLASS = PokeVersion
      CSV_PATH = "data/v2/csv/versions.csv"
      BATCH_SIZE = 500
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          version_group_id: optional_value(csv_row, :version_group_id)&.to_i
        )
      end
    end
  end
end
