module Pokeapi
  module Importers
    class PokemonItemImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonItem
      CSV_PATH = "data/v2/csv/pokemon_items.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          pokemon_id: required_value(csv_row, :pokemon_id).to_i,
          version_id: required_value(csv_row, :version_id).to_i,
          item_id: required_value(csv_row, :item_id).to_i,
          rarity: required_value(csv_row, :rarity).to_i
        )
      end
    end
  end
end
