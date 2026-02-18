module Pokeapi
  module Importers
    class CharacteristicImporter < BaseCsvImporter
      MODEL_CLASS = PokeCharacteristic
      CSV_PATH = "data/v2/csv/characteristics.csv"
      BATCH_SIZE = 100

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          stat_id: optional_value(csv_row, :stat_id)&.to_i,
          gene_mod_5: optional_value(csv_row, :gene_mod_5)&.to_i
        )
      end
    end
  end
end
