module Pokeapi
  module Importers
    class EncounterSlotImporter < BaseCsvImporter
      MODEL_CLASS = PokeEncounterSlot
      CSV_PATH = "data/v2/csv/encounter_slots.csv"
      BATCH_SIZE = 2_000

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          version_group_id: required_value(csv_row, :version_group_id).to_i,
          encounter_method_id: required_value(csv_row, :encounter_method_id).to_i,
          slot: optional_value(csv_row, :slot)&.to_i,
          rarity: required_value(csv_row, :rarity).to_i
        )
      end
    end
  end
end
