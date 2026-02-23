module Api
  module V3
    class MoveBattleStyleController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeMoveBattleStyle.order(:id),
          cache_key: "v3/move_battle_style#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        move_battle_style = find_by_id_or_name!(PokeMoveBattleStyle.all, params[:id])
        render_show_flow(record: move_battle_style, cache_key: "v3/move_battle_style#show")
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

      def summary_payload(move_battle_style, includes:, include_map:)
        {
          id: move_battle_style.id,
          name: move_battle_style.name,
          url: canonical_url_for(move_battle_style, :api_v3_move_battle_style_url)
        }
      end

      def detail_payload(move_battle_style, includes:, include_map:)
        {
          id: move_battle_style.id,
          name: move_battle_style.name,
          url: canonical_url_for(move_battle_style, :api_v3_move_battle_style_url)
        }
      end
    end
  end
end
