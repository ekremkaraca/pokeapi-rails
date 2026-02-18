module Pokeapi
  module Importers
    class MachineImporter < BaseCsvImporter
      MODEL_CLASS = PokeMachine
      CSV_PATH = "data/v2/csv/machines.csv"
      BATCH_SIZE = 1_000
      KEY_MAPPING = {
        machine_number: :machine_number,
        version_group_id: :version_group_id,
        item_id: :item_id,
        move_id: :move_id
      }

      def run!
        @next_import_id = 0
        super
      end

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: next_import_id,
          machine_number: optional_value(csv_row, :machine_number)&.to_i,
          version_group_id: optional_value(csv_row, :version_group_id)&.to_i,
          item_id: optional_value(csv_row, :item_id)&.to_i,
          move_id: optional_value(csv_row, :move_id)&.to_i
        )
      end

      def next_import_id
        @next_import_id ||= 0
        @next_import_id += 1
      end
    end
  end
end
