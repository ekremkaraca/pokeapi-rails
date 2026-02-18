module Api
  module V2
    class BerryController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeBerry
      RESOURCE_URL_HELPER = :api_v2_berry_url


      private

      def detail_extras(berry)
        {
          item_id: berry.item_id,
          firmness_id: berry.berry_firmness_id,
          natural_gift_power: berry.natural_gift_power,
          natural_gift_type_id: berry.natural_gift_type_id,
          size: berry.size,
          max_harvest: berry.max_harvest,
          growth_time: berry.growth_time,
          soil_dryness: berry.soil_dryness,
          smoothness: berry.smoothness
        }
      end
    end
  end
end
