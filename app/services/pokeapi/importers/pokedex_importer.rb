module Pokeapi
  module Importers
    class PokedexImporter < BaseCsvImporter
      MODEL_CLASS = PokePokedex
      CSV_PATH = "data/v2/csv/pokedexes.csv"
      BATCH_SIZE = 200
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          region_id: optional_value(csv_row, :region_id)&.to_i,
          is_main_series: to_bool(required_value(csv_row, :is_main_series))
        )
      end
    end
  end
end
