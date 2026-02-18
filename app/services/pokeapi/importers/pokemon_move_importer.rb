module Pokeapi
  module Importers
    class PokemonMoveImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonMove
      CSV_PATH = "data/v2/csv/pokemon_moves.csv"
      BATCH_SIZE = 20_000
      KEY_MAPPING = { "order": :sort_order }

      private

      def insert_rows(rows)
        model_class.insert_all(rows, unique_by: :idx_pokemon_move_uniqueness, returning: false)
      end

      def normalize_row(csv_row)
        with_timestamps(
          pokemon_id: required_value(csv_row, :pokemon_id).to_i,
          version_group_id: required_value(csv_row, :version_group_id).to_i,
          move_id: required_value(csv_row, :move_id).to_i,
          pokemon_move_method_id: required_value(csv_row, :pokemon_move_method_id).to_i,
          level: required_value(csv_row, :level).to_i,
          sort_order: optional_value(csv_row, :sort_order, :order, :order_)&.to_i,
          mastery: optional_value(csv_row, :mastery)&.to_i
        )
      end
    end
  end
end
