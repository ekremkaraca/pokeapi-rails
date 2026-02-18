module Api
  module V2
    class EncounterMethodController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeEncounterMethod
      RESOURCE_URL_HELPER = :api_v2_encounter_method_url


      private

      def detail_extras(method)
        {
          order: method.sort_order
        }
      end
    end
  end
end
