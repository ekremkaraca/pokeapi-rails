module Api
  module V2
    class MoveController < BaseController
      include NameSearchableResource
      include MoveDetailPayload

      MODEL_CLASS = PokeMove
      RESOURCE_URL_HELPER = :api_v2_move_url
    end
  end
end
