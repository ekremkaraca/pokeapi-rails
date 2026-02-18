module Pokeapi
  module Importers
    class VersionGroupImporter < BaseCsvImporter
      MODEL_CLASS = PokeVersionGroup
      CSV_PATH = "data/v2/csv/version_groups.csv"
      BATCH_SIZE = 500
      KEY_MAPPING = {
        identifier: :name,
        "order": :sort_order
      }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          generation_id: optional_value(csv_row, :generation_id)&.to_i,
          sort_order: optional_value(csv_row, :sort_order, :order)&.to_i
        )
      end
    end
  end
end
