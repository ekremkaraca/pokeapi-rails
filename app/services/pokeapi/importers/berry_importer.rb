module Pokeapi
  module Importers
    class BerryImporter < BaseCsvImporter
      MODEL_CLASS = PokeBerry
      CSV_PATH = "data/v2/csv/berries.csv"
      BATCH_SIZE = 500

      private

      def normalize_row(csv_row)
        item_id = required_value(csv_row, :item_id).to_i

        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          item_id: item_id,
          name: berry_name_for_item(item_id),
          berry_firmness_id: required_value(csv_row, :firmness_id).to_i,
          natural_gift_power: required_value(csv_row, :natural_gift_power).to_i,
          natural_gift_type_id: required_value(csv_row, :natural_gift_type_id).to_i,
          size: required_value(csv_row, :size).to_i,
          max_harvest: required_value(csv_row, :max_harvest).to_i,
          growth_time: required_value(csv_row, :growth_time).to_i,
          soil_dryness: required_value(csv_row, :soil_dryness).to_i,
          smoothness: required_value(csv_row, :smoothness).to_i
        )
      end

      def berry_name_for_item(item_id)
        item_name = PokeItem.find(item_id).name
        item_name.split("-", 2).first
      end
    end
  end
end
