module Api
  module V2
    class EncounterConditionController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeEncounterCondition
      RESOURCE_URL_HELPER = :api_v2_encounter_condition_url

    end
  end
end
