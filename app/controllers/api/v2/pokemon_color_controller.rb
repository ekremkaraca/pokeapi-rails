module Api
  module V2
    class PokemonColorController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokePokemonColor
      RESOURCE_URL_HELPER = :api_v2_pokemon_color_url
    end
  end
end
