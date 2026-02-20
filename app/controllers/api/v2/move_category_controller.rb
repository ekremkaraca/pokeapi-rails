module Api
  module V2
    class MoveCategoryController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeMoveMetaCategory
      RESOURCE_URL_HELPER = :api_v2_move_category_url
    end
  end
end
