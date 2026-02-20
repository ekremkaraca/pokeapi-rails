module Api
  module V2
    class MoveLearnMethodController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeMoveLearnMethod
      RESOURCE_URL_HELPER = :api_v2_move_learn_method_url
    end
  end
end
