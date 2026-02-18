module Api
  module V2
    class RegionController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeRegion
      RESOURCE_URL_HELPER = :api_v2_region_url

    end
  end
end
