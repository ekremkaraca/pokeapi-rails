module Pokeapi
  module Importers
    class MoveFlavorTextImporter < BaseCsvImporter
      MODEL_CLASS = PokeMoveFlavorText
      CSV_PATH = "data/v2/csv/move_flavor_text.csv"
      BATCH_SIZE = 5_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          move_id: required_value(csv_row, :move_id).to_i,
          version_group_id: required_value(csv_row, :version_group_id).to_i,
          language_id: required_value(csv_row, :language_id).to_i,
          flavor_text: optional_value(csv_row, :flavor_text)
        )
      end
    end
  end
end
