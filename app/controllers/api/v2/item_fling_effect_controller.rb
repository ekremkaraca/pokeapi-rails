module Api
  module V2
    class ItemFlingEffectController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeItemFlingEffect
      RESOURCE_URL_HELPER = :api_v2_item_fling_effect_url
    end
  end
end
