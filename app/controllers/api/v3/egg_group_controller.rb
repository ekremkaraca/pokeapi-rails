module Api
  module V3
    class EggGroupController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeEggGroup.order(:id),
          cache_key: "v3/egg-group#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        egg_group = find_by_id_or_name!(PokeEggGroup.all, params[:id])
        render_show_flow(record: egg_group, cache_key: "v3/egg-group#show")
      end

      private

      def summary_fields
        %i[id name url]
      end

      def detail_fields
        %i[id name url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(egg_group, includes:, include_map:)
        {
          id: egg_group.id,
          name: egg_group.name,
          url: canonical_url_for(egg_group, :api_v3_egg_group_url)
        }
      end

      def detail_payload(egg_group, includes:, include_map:)
        {
          id: egg_group.id,
          name: egg_group.name,
          url: canonical_url_for(egg_group, :api_v3_egg_group_url)
        }
      end
    end
  end
end
