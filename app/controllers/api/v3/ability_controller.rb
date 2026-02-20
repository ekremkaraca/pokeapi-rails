module Api
  module V3
    class AbilityController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: Ability.order(:id),
          cache_key: "v3/ability#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        ability = Ability.find(require_numeric_id!(params[:id]))
        render_show_flow(record: ability, cache_key: "v3/ability#show")
      end

      private

      def summary_fields
        %i[id name url pokemon]
      end

      def detail_fields
        %i[id name is_main_series url pokemon]
      end

      def summary_includes
        %i[pokemon]
      end

      def detail_includes
        %i[pokemon]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :pokemon, loader: :pokemon_by_ability_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :pokemon, loader: :pokemon_by_ability_id)
      end

      def summary_payload(ability, includes:, include_map:)
        payload = {
          id: ability.id,
          name: ability.name,
          url: canonical_url_for(ability, :api_v3_ability_url)
        }
        payload[:pokemon] = include_map.fetch(ability.id, []) if includes.include?(:pokemon)
        payload
      end

      def detail_payload(ability, includes:, include_map:)
        payload = {
          id: ability.id,
          name: ability.name,
          is_main_series: ability.is_main_series,
          url: canonical_url_for(ability, :api_v3_ability_url)
        }
        payload[:pokemon] = include_map.fetch(ability.id, []) if includes.include?(:pokemon)
        payload
      end

    end
  end
end
