module Api
  module V2
    class EvolutionTriggerController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeEvolutionTrigger
      RESOURCE_URL_HELPER = :api_v2_evolution_trigger_url
    end
  end
end
