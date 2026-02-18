module Pokeapi
  module Importers
    class PokemonStatImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonStat
      CSV_PATH = "data/v2/csv/pokemon_stats.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          pokemon_id: required_value(csv_row, :pokemon_id).to_i,
          stat_id: required_value(csv_row, :stat_id).to_i,
          base_stat: required_value(csv_row, :base_stat).to_i,
          effort: required_value(csv_row, :effort).to_i
        )
      end
    end
  end
end
