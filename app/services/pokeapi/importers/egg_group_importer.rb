module Pokeapi
  module Importers
    class EggGroupImporter < BaseCsvImporter
      MODEL_CLASS = PokeEggGroup
      CSV_PATH = "data/v2/csv/egg_groups.csv"
      BATCH_SIZE = 100
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier)
        )
      end
    end
  end
end
