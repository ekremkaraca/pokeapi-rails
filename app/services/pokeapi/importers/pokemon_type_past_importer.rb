module Pokeapi
  module Importers
    class PokemonTypePastImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonTypePast
      CSV_PATH = "data/v2/csv/pokemon_types_past.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          pokemon_id: required_value(csv_row, :pokemon_id).to_i,
          generation_id: required_value(csv_row, :generation_id).to_i,
          type_id: required_value(csv_row, :type_id).to_i,
          slot: required_value(csv_row, :slot).to_i
        )
      end
    end
  end
end
