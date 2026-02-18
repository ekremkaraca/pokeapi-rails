module Api
  module V2
    class MoveDamageClassController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeMoveDamageClass
      RESOURCE_URL_HELPER = :api_v2_move_damage_class_url

    end
  end
end
