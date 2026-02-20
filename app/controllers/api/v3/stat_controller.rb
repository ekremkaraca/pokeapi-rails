module Api
  module V3
    class StatController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeStat.order(:id),
          cache_key: "v3/stat#index",
          sort_allowed: %i[id name game_index damage_class_id is_battle_only],
          sort_default: "id"
        )
      end

      def show
        stat = PokeStat.find(require_numeric_id!(params[:id]))
        render_show_flow(record: stat, cache_key: "v3/stat#show")
      end

      private

      def summary_fields
        %i[id name game_index damage_class_id is_battle_only url]
      end

      def detail_fields
        %i[id name game_index damage_class_id is_battle_only url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(stat, includes:, include_map:)
        {
          id: stat.id,
          name: stat.name,
          game_index: stat.game_index,
          damage_class_id: stat.damage_class_id,
          is_battle_only: stat.is_battle_only,
          url: canonical_url_for(stat, :api_v3_stat_url)
        }
      end

      def detail_payload(stat, includes:, include_map:)
        {
          id: stat.id,
          name: stat.name,
          game_index: stat.game_index,
          damage_class_id: stat.damage_class_id,
          is_battle_only: stat.is_battle_only,
          url: canonical_url_for(stat, :api_v3_stat_url)
        }
      end
    end
  end
end
