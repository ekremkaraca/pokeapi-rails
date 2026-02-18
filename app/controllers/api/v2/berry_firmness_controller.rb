module Api
  module V2
    class BerryFirmnessController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeBerryFirmness
      RESOURCE_URL_HELPER = :api_v2_berry_firmness_url

    end
  end
end
