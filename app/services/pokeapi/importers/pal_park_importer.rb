module Pokeapi
  module Importers
    class PalParkImporter < BaseCsvImporter
      MODEL_CLASS = PokePalPark
      CSV_PATH = "data/v2/csv/pal_park.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          species_id: required_value(csv_row, :species_id).to_i,
          area_id: required_value(csv_row, :area_id).to_i,
          base_score: required_value(csv_row, :base_score).to_i,
          rate: required_value(csv_row, :rate).to_i
        )
      end
    end
  end
end
