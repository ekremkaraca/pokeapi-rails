module Pokeapi
  module Importers
    class AbilityChangelogImporter < BaseCsvImporter
      MODEL_CLASS = PokeAbilityChangelog
      CSV_PATH = "data/v2/csv/ability_changelog.csv"
      BATCH_SIZE = 200

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          ability_id: required_value(csv_row, :ability_id).to_i,
          changed_in_version_group_id: required_value(csv_row, :changed_in_version_group_id).to_i
        )
      end
    end
  end
end
