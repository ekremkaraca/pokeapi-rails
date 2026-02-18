module Api
  module V2
    class GenderController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeGender
      RESOURCE_URL_HELPER = :api_v2_gender_url
    end
  end
end
