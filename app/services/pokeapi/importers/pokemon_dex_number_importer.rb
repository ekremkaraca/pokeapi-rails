module Pokeapi
  module Importers
    class PokemonDexNumberImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonDexNumber
      CSV_PATH = "data/v2/csv/pokemon_dex_numbers.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          species_id: required_value(csv_row, :species_id).to_i,
          pokedex_id: required_value(csv_row, :pokedex_id).to_i,
          pokedex_number: required_value(csv_row, :pokedex_number).to_i
        )
      end
    end
  end
end
