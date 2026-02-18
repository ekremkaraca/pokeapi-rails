module Api
  module V2
    class EggGroupController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeEggGroup
      RESOURCE_URL_HELPER = :api_v2_egg_group_url
    end
  end
end
