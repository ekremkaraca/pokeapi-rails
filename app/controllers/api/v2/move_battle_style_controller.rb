module Api
  module V2
    class MoveBattleStyleController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeMoveBattleStyle
      RESOURCE_URL_HELPER = :api_v2_move_battle_style_url
    end
  end
end
