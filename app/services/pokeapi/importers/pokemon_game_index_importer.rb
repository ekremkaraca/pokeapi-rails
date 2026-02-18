module Pokeapi
  module Importers
    class PokemonGameIndexImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonGameIndex
      CSV_PATH = "data/v2/csv/pokemon_game_indices.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          pokemon_id: required_value(csv_row, :pokemon_id).to_i,
          version_id: required_value(csv_row, :version_id).to_i,
          game_index: required_value(csv_row, :game_index).to_i
        )
      end
    end
  end
end
