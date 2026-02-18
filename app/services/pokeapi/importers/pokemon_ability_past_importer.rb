module Pokeapi
  module Importers
    class PokemonAbilityPastImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonAbilityPast
      CSV_PATH = "data/v2/csv/pokemon_abilities_past.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          pokemon_id: required_value(csv_row, :pokemon_id).to_i,
          generation_id: required_value(csv_row, :generation_id).to_i,
          ability_id: optional_value(csv_row, :ability_id)&.presence&.to_i,
          is_hidden: to_bool(required_value(csv_row, :is_hidden)),
          slot: required_value(csv_row, :slot).to_i
        )
      end
    end
  end
end
