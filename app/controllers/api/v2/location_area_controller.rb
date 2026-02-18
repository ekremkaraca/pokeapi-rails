module Api
  module V2
    class LocationAreaController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeLocationArea
      RESOURCE_URL_HELPER = :api_v2_location_area_url


      private

      def detail_extras(location_area)
        {
          location_id: location_area.location_id,
          game_index: location_area.game_index
        }
      end
    end
  end
end
