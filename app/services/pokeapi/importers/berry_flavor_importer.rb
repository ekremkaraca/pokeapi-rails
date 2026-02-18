module Pokeapi
  module Importers
    class BerryFlavorImporter < BaseCsvImporter
      MODEL_CLASS = PokeBerryFlavor
      CSV_PATH = "data/v2/csv/contest_type_names.csv"
      BATCH_SIZE = 100
      KEY_MAPPING = { contest_type_id: :id }
      ENGLISH_LANGUAGE_ID = 9

      private

      def normalize_row(csv_row)
        language_id = required_value(csv_row, :local_language_id).to_i
        return nil unless language_id == ENGLISH_LANGUAGE_ID

        contest_type_id = required_value(csv_row, :id, :contest_type_id).to_i

        with_timestamps(
          id: contest_type_id,
          contest_type_id: contest_type_id,
          name: required_value(csv_row, :flavor).to_s.downcase
        )
      end
    end
  end
end
