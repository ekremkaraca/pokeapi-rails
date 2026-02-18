module Api
  module V2
    class PokemonShapeController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokePokemonShape
      RESOURCE_URL_HELPER = :api_v2_pokemon_shape_url
    end
  end
end
