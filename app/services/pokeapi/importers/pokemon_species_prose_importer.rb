module Pokeapi
  module Importers
    class PokemonSpeciesProseImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonSpeciesProse
      CSV_PATH = "data/v2/csv/pokemon_species_prose.csv"
      BATCH_SIZE = 1_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          pokemon_species_id: required_value(csv_row, :pokemon_species_id).to_i,
          local_language_id: required_value(csv_row, :local_language_id).to_i,
          form_description: optional_value(csv_row, :form_description)
        )
      end
    end
  end
end
