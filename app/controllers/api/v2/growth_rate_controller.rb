module Api
  module V2
    class GrowthRateController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeGrowthRate
      RESOURCE_URL_HELPER = :api_v2_growth_rate_url

      private

      def detail_extras(growth_rate)
        {
          formula: growth_rate.formula
        }
      end
    end
  end
end
