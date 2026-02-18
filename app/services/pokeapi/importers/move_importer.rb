module Pokeapi
  module Importers
    class MoveImporter < BaseCsvImporter
      MODEL_CLASS = PokeMove
      CSV_PATH = "data/v2/csv/moves.csv"
      BATCH_SIZE = 1_000
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          generation_id: optional_value(csv_row, :generation_id)&.to_i,
          type_id: optional_value(csv_row, :type_id)&.to_i,
          power: optional_value(csv_row, :power)&.to_i,
          pp: optional_value(csv_row, :pp)&.to_i,
          accuracy: optional_value(csv_row, :accuracy)&.to_i,
          priority: optional_value(csv_row, :priority)&.to_i,
          target_id: optional_value(csv_row, :target_id)&.to_i,
          damage_class_id: optional_value(csv_row, :damage_class_id)&.to_i,
          effect_id: optional_value(csv_row, :effect_id)&.to_i,
          effect_chance: optional_value(csv_row, :effect_chance)&.to_i,
          contest_type_id: optional_value(csv_row, :contest_type_id)&.to_i,
          contest_effect_id: optional_value(csv_row, :contest_effect_id)&.to_i,
          super_contest_effect_id: optional_value(csv_row, :super_contest_effect_id)&.to_i
        )
      end
    end
  end
end
