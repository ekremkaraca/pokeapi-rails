module Api
  module V2
    class PalParkAreaController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokePalParkArea
      RESOURCE_URL_HELPER = :api_v2_pal_park_area_url

    end
  end
end
