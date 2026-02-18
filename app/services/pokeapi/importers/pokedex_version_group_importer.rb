module Pokeapi
  module Importers
    class PokedexVersionGroupImporter < BaseCsvImporter
      MODEL_CLASS = PokePokedexVersionGroup
      CSV_PATH = "data/v2/csv/pokedex_version_groups.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          pokedex_id: required_value(csv_row, :pokedex_id).to_i,
          version_group_id: required_value(csv_row, :version_group_id).to_i
        )
      end
    end
  end
end
