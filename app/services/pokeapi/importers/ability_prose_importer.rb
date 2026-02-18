module Pokeapi
  module Importers
    class AbilityProseImporter < BaseCsvImporter
      MODEL_CLASS = PokeAbilityProse
      CSV_PATH = "data/v2/csv/ability_prose.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          ability_id: required_value(csv_row, :ability_id).to_i,
          local_language_id: required_value(csv_row, :local_language_id).to_i,
          short_effect: optional_value(csv_row, :short_effect),
          effect: optional_value(csv_row, :effect)
        )
      end
    end
  end
end
