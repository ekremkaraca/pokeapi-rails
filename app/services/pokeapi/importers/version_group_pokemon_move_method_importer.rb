module Pokeapi
  module Importers
    class VersionGroupPokemonMoveMethodImporter < BaseCsvImporter
      MODEL_CLASS = PokeVersionGroupPokemonMoveMethod
      CSV_PATH = "data/v2/csv/version_group_pokemon_move_methods.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          version_group_id: required_value(csv_row, :version_group_id).to_i,
          pokemon_move_method_id: required_value(csv_row, :pokemon_move_method_id).to_i
        )
      end
    end
  end
end
