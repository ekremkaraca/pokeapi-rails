module Pokeapi
  module Importers
    class VersionGroupRegionImporter < BaseCsvImporter
      MODEL_CLASS = PokeVersionGroupRegion
      CSV_PATH = "data/v2/csv/version_group_regions.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          version_group_id: required_value(csv_row, :version_group_id).to_i,
          region_id: required_value(csv_row, :region_id).to_i
        )
      end
    end
  end
end
