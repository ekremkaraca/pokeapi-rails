module Pokeapi
  module Importers
    class PokemonSpeciesImporter < BaseCsvImporter
      MODEL_CLASS = PokePokemonSpecies
      CSV_PATH = "data/v2/csv/pokemon_species.csv"
      BATCH_SIZE = 500
      KEY_MAPPING = {
        identifier: :name,
        "order": :sort_order
      }

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          name: required_value(csv_row, :name, :identifier),
          generation_id: optional_value(csv_row, :generation_id)&.to_i,
          evolves_from_species_id: optional_value(csv_row, :evolves_from_species_id)&.to_i,
          evolution_chain_id: optional_value(csv_row, :evolution_chain_id)&.to_i,
          color_id: optional_value(csv_row, :color_id)&.to_i,
          shape_id: optional_value(csv_row, :shape_id)&.to_i,
          habitat_id: optional_value(csv_row, :habitat_id)&.to_i,
          gender_rate: optional_value(csv_row, :gender_rate)&.to_i,
          capture_rate: optional_value(csv_row, :capture_rate)&.to_i,
          base_happiness: optional_value(csv_row, :base_happiness)&.to_i,
          is_baby: to_bool(required_value(csv_row, :is_baby)),
          hatch_counter: optional_value(csv_row, :hatch_counter)&.to_i,
          has_gender_differences: to_bool(required_value(csv_row, :has_gender_differences)),
          growth_rate_id: optional_value(csv_row, :growth_rate_id)&.to_i,
          forms_switchable: to_bool(required_value(csv_row, :forms_switchable)),
          is_legendary: to_bool(required_value(csv_row, :is_legendary)),
          is_mythical: to_bool(required_value(csv_row, :is_mythical)),
          sort_order: optional_value(csv_row, :sort_order, :order, :order_)&.to_i,
          conquest_order: optional_value(csv_row, :conquest_order)&.to_i
        )
      end
    end
  end
end
