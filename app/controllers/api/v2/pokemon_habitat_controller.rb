module Api
  module V2
    class PokemonHabitatController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokePokemonHabitat
      RESOURCE_URL_HELPER = :api_v2_pokemon_habitat_url
    end
  end
end
