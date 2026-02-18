module Api
  module V2
    class NatureController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeNature
      RESOURCE_URL_HELPER = :api_v2_nature_url

      private

      def detail_extras(nature)
        {
          decreased_stat_id: nature.decreased_stat_id,
          increased_stat_id: nature.increased_stat_id,
          hates_flavor_id: nature.hates_flavor_id,
          likes_flavor_id: nature.likes_flavor_id,
          game_index: nature.game_index
        }
      end
    end
  end
end
