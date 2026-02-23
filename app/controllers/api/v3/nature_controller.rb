module Api
  module V3
    class NatureController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeNature.order(:id),
          cache_key: "v3/nature#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        nature = find_by_id_or_name!(PokeNature.all, params[:id])
        render_show_flow(record: nature, cache_key: "v3/nature#show")
      end

      private

      def summary_fields
        %i[id name url]
      end

      def detail_fields
        %i[id name decreased_stat_id increased_stat_id hates_flavor_id likes_flavor_id game_index url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(nature, includes:, include_map:)
        {
          id: nature.id,
          name: nature.name,
          url: canonical_url_for(nature, :api_v3_nature_url)
        }
      end

      def detail_payload(nature, includes:, include_map:)
        {
          id: nature.id,
          name: nature.name,
          decreased_stat_id: nature.decreased_stat_id,
          increased_stat_id: nature.increased_stat_id,
          hates_flavor_id: nature.hates_flavor_id,
          likes_flavor_id: nature.likes_flavor_id,
          game_index: nature.game_index,
          url: canonical_url_for(nature, :api_v3_nature_url)
        }
      end
    end
  end
end
