module Api
  module V2
    class MoveAilmentController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeMoveAilment
      RESOURCE_URL_HELPER = :api_v2_move_ailment_url

    end
  end
end
