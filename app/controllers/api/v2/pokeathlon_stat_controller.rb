module Api
  module V2
    class PokeathlonStatController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokePokeathlonStat
      RESOURCE_URL_HELPER = :api_v2_pokeathlon_stat_url
    end
  end
end
