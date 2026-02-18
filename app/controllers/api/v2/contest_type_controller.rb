module Api
  module V2
    class ContestTypeController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeContestType
      RESOURCE_URL_HELPER = :api_v2_contest_type_url

    end
  end
end
