module Api
  module V2
    class PokemonFormController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokePokemonForm
      RESOURCE_URL_HELPER = :api_v2_pokemon_form_url

      private

      def detail_extras(pokemon_form)
        {
          form_name: pokemon_form.form_name,
          pokemon_id: pokemon_form.pokemon_id,
          introduced_in_version_group_id: pokemon_form.introduced_in_version_group_id,
          is_default: pokemon_form.is_default,
          is_battle_only: pokemon_form.is_battle_only,
          is_mega: pokemon_form.is_mega,
          form_order: pokemon_form.form_order,
          sort_order: pokemon_form.sort_order
        }
      end
    end
  end
end
