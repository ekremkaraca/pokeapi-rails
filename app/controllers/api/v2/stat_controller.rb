module Api
  module V2
    class StatController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeStat
      RESOURCE_URL_HELPER = :api_v2_stat_url


      private

      def detail_extras(stat)
        {
          is_battle_only: stat.is_battle_only
        }
      end
    end
  end
end
