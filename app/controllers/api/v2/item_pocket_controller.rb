module Api
  module V2
    class ItemPocketController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeItemPocket
      RESOURCE_URL_HELPER = :api_v2_item_pocket_url
    end
  end
end
