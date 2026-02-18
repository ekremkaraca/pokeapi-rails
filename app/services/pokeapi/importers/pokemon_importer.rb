module Pokeapi
  module Importers
    class PokemonImporter < BaseCsvImporter
      MODEL_CLASS = Pokemon
      CSV_PATH = "data/v2/csv/pokemon.csv"
      BATCH_SIZE = 1_000
      KEY_MAPPING = {
        identifier: :name,
        "order": :sort_order
      }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          species_id: required_value(csv_row, :species_id).to_i,
          height: required_value(csv_row, :height).to_i,
          weight: required_value(csv_row, :weight).to_i,
          base_experience: optional_value(csv_row, :base_experience)&.to_i,
          sort_order: optional_value(csv_row, :sort_order, :order, :order_)&.to_i,
          is_default: to_bool(required_value(csv_row, :is_default))
        )
      end
    end
  end
end
