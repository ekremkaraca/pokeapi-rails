module Api
  module V2
    class ItemCategoryController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeItemCategory
      RESOURCE_URL_HELPER = :api_v2_item_category_url


      private

      def detail_extras(category)
        {
          pocket_id: category.pocket_id
        }
      end
    end
  end
end
