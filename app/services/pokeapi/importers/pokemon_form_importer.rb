module Pokeapi
  module Importers
    class PokemonFormImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonForm
      CSV_PATH = "data/v2/csv/pokemon_forms.csv"
      BATCH_SIZE = 500
      KEY_MAPPING = {
        identifier: :name,
        form_identifier: :form_name,
        "order": :sort_order
      }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          form_name: optional_value(csv_row, :form_name, :form_identifier).presence,
          pokemon_id: optional_value(csv_row, :pokemon_id)&.to_i,
          introduced_in_version_group_id: optional_value(csv_row, :introduced_in_version_group_id)&.to_i,
          is_default: to_bool(required_value(csv_row, :is_default)),
          is_battle_only: to_bool(required_value(csv_row, :is_battle_only)),
          is_mega: to_bool(required_value(csv_row, :is_mega)),
          form_order: optional_value(csv_row, :form_order)&.to_i,
          sort_order: optional_value(csv_row, :sort_order, :order, :order_)&.to_i
        )
      end
    end
  end
end
