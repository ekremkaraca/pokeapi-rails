module Api
  module V3
    class PokemonFormController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokePokemonForm.order(:id),
          cache_key: "v3/pokemon_form#index",
          sort_allowed: %i[id name pokemon_id sort_order],
          sort_default: "id"
        )
      end

      def show
        pokemon_form = PokePokemonForm.find(require_numeric_id!(params[:id]))
        render_show_flow(record: pokemon_form, cache_key: "v3/pokemon_form#show")
      end

      private

      def summary_fields
        %i[id name form_name pokemon_id introduced_in_version_group_id is_default is_battle_only is_mega form_order sort_order url]
      end

      def detail_fields
        %i[id name form_name pokemon_id introduced_in_version_group_id is_default is_battle_only is_mega form_order sort_order url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(pokemon_form, includes:, include_map:)
        {
          id: pokemon_form.id,
          name: pokemon_form.name,
          form_name: pokemon_form.form_name,
          pokemon_id: pokemon_form.pokemon_id,
          introduced_in_version_group_id: pokemon_form.introduced_in_version_group_id,
          is_default: pokemon_form.is_default,
          is_battle_only: pokemon_form.is_battle_only,
          is_mega: pokemon_form.is_mega,
          form_order: pokemon_form.form_order,
          sort_order: pokemon_form.sort_order,
          url: canonical_url_for(pokemon_form, :api_v3_pokemon_form_url)
        }
      end

      def detail_payload(pokemon_form, includes:, include_map:)
        summary_payload(pokemon_form, includes: includes, include_map: include_map)
      end
    end
  end
end
