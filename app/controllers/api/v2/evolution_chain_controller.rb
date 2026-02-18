module Api
  module V2
    class EvolutionChainController < BaseController
      include IdOnlyResource

      MODEL_CLASS = PokeEvolutionChain
      RESOURCE_URL_HELPER = :api_v2_evolution_chain_url

      private

      def detail_extras(evolution_chain)
        {
          baby_trigger_item_id: evolution_chain.baby_trigger_item_id
        }
      end
    end
  end
end
