module Api
  module V2
    class ItemAttributeController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeItemAttribute
      RESOURCE_URL_HELPER = :api_v2_item_attribute_url
    end
  end
end
