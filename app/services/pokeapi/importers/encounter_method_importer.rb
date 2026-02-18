module Pokeapi
  module Importers
    class EncounterMethodImporter < BaseCsvImporter
      MODEL_CLASS = PokeEncounterMethod
      CSV_PATH = "data/v2/csv/encounter_methods.csv"
      BATCH_SIZE = 200
      KEY_MAPPING = {
        identifier: :name,
        "order": :sort_order
      }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          sort_order: required_value(csv_row, :sort_order, :order).to_i
        )
      end
    end
  end
end
