module Pokeapi
  module Importers
    class PokemonEggGroupImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonEggGroup
      CSV_PATH = "data/v2/csv/pokemon_egg_groups.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          species_id: required_value(csv_row, :species_id).to_i,
          egg_group_id: required_value(csv_row, :egg_group_id).to_i
        )
      end
    end
  end
end
