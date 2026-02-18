module Api
  module V2
    class MoveTargetController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeMoveTarget
      RESOURCE_URL_HELPER = :api_v2_move_target_url

    end
  end
end
