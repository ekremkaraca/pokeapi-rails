module Pokeapi
  module Importers
    class MoveAilmentImporter < BaseCsvImporter
      MODEL_CLASS = PokeMoveAilment
      CSV_PATH = "data/v2/csv/move_meta_ailments.csv"
      BATCH_SIZE = 100
      KEY_MAPPING = { identifier: :name }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier)
        )
      end

      def reset_primary_key_sequence!
        sequence_name = model_class.connection.default_sequence_name(model_class.table_name, "id")
        next_value = [ model_class.maximum(:id).to_i, 1 ].max

        model_class.connection.execute(
          "SELECT setval(#{model_class.connection.quote(sequence_name)}, #{next_value}, true)"
        )
      end
    end
  end
end
