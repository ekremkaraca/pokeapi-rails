module Api
  module V3
    class MoveTargetController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeMoveTarget.order(:id),
          cache_key: "v3/move_target#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        move_target = PokeMoveTarget.find(require_numeric_id!(params[:id]))
        render_show_flow(record: move_target, cache_key: "v3/move_target#show")
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

      def summary_payload(move_target, includes:, include_map:)
        {
          id: move_target.id,
          name: move_target.name,
          url: canonical_url_for(move_target, :api_v3_move_target_url)
        }
      end

      def detail_payload(move_target, includes:, include_map:)
        {
          id: move_target.id,
          name: move_target.name,
          url: canonical_url_for(move_target, :api_v3_move_target_url)
        }
      end
    end
  end
end
