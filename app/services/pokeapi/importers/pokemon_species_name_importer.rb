module Pokeapi
  module Importers
    class PokemonSpeciesNameImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonSpeciesName
      CSV_PATH = "data/v2/csv/pokemon_species_names.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          pokemon_species_id: required_value(csv_row, :pokemon_species_id).to_i,
          local_language_id: required_value(csv_row, :local_language_id).to_i,
          name: optional_value(csv_row, :name),
          genus: optional_value(csv_row, :genus)
        )
      end
    end
  end
end
