module Api
  module V2
    class EncounterConditionValueController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeEncounterConditionValue
      RESOURCE_URL_HELPER = :api_v2_encounter_condition_value_url


      private

      def detail_extras(condition_value)
        {
          encounter_condition_id: condition_value.encounter_condition_id,
          is_default: condition_value.is_default
        }
      end
    end
  end
end
