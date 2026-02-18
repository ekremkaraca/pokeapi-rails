module Api
  module V2
    class BerryFlavorController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeBerryFlavor
      RESOURCE_URL_HELPER = :api_v2_berry_flavor_url


      private

      def detail_extras(flavor)
        {
          contest_type_id: flavor.contest_type_id
        }
      end
    end
  end
end
