module Pokeapi
  module Importers
    class NatureImporter < BaseCsvImporter
      MODEL_CLASS = PokeNature
      CSV_PATH = "data/v2/csv/natures.csv"
      BATCH_SIZE = 200
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          decreased_stat_id: optional_value(csv_row, :decreased_stat_id)&.to_i,
          increased_stat_id: optional_value(csv_row, :increased_stat_id)&.to_i,
          hates_flavor_id: optional_value(csv_row, :hates_flavor_id)&.to_i,
          likes_flavor_id: optional_value(csv_row, :likes_flavor_id)&.to_i,
          game_index: optional_value(csv_row, :game_index)&.to_i
        )
      end
    end
  end
end
