module Pokeapi
  module Importers
    class PokemonAbilityImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonAbility
      CSV_PATH = "data/v2/csv/pokemon_abilities.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          pokemon_id: required_value(csv_row, :pokemon_id).to_i,
          ability_id: required_value(csv_row, :ability_id).to_i,
          is_hidden: to_bool(required_value(csv_row, :is_hidden)),
          slot: required_value(csv_row, :slot).to_i
        )
      end
    end
  end
end
