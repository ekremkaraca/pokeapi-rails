module Pokeapi
  module Importers
    class StatImporter < BaseCsvImporter
      MODEL_CLASS = PokeStat
      CSV_PATH = "data/v2/csv/stats.csv"
      BATCH_SIZE = 200
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          damage_class_id: optional_value(csv_row, :damage_class_id)&.to_i,
          is_battle_only: to_bool(required_value(csv_row, :is_battle_only)),
          game_index: optional_value(csv_row, :game_index)&.to_i
        )
      end
    end
  end
end
