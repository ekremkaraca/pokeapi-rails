module Api
  module V2
    class PokedexController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokePokedex
      RESOURCE_URL_HELPER = :api_v2_pokedex_url


      private

      def detail_extras(pokedex)
        {
          is_main_series: pokedex.is_main_series,
          region_id: pokedex.region_id
        }
      end
    end
  end
end
