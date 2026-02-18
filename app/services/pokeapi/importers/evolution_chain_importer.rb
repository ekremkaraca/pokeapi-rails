module Pokeapi
  module Importers
    class EvolutionChainImporter < BaseCsvImporter
      MODEL_CLASS = PokeEvolutionChain
      CSV_PATH = "data/v2/csv/evolution_chains.csv"
      BATCH_SIZE = 200

      private

      def normalize_row(csv_row)
        with_timestamps(
          id: required_value(csv_row, :id).to_i,
          baby_trigger_item_id: optional_value(csv_row, :baby_trigger_item_id)&.to_i
        )
      end
    end
  end
end
