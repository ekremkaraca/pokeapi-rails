module Pokeapi
  module Importers
    class LanguageImporter < BaseCsvImporter
      MODEL_CLASS = PokeLanguage
      CSV_PATH = "data/v2/csv/languages.csv"
      BATCH_SIZE = 200
      KEY_MAPPING = {
        identifier: :name,
        iso639: :iso639,
        iso3166: :iso3166,
        official: :official,
        "order": :sort_order
      }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          iso639: optional_value(csv_row, :iso639),
          iso3166: optional_value(csv_row, :iso3166),
          official: to_bool(required_value(csv_row, :official)),
          sort_order: optional_value(csv_row, :sort_order, :order)&.to_i
        )
      end
    end
  end
end
