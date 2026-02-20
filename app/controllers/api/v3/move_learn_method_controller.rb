module Api
  module V3
    class MoveLearnMethodController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeMoveLearnMethod.order(:id),
          cache_key: "v3/move_learn_method#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        move_learn_method = PokeMoveLearnMethod.find(require_numeric_id!(params[:id]))
        render_show_flow(record: move_learn_method, cache_key: "v3/move_learn_method#show")
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

      def summary_payload(move_learn_method, includes:, include_map:)
        {
          id: move_learn_method.id,
          name: move_learn_method.name,
          url: canonical_url_for(move_learn_method, :api_v3_move_learn_method_url)
        }
      end

      def detail_payload(move_learn_method, includes:, include_map:)
        {
          id: move_learn_method.id,
          name: move_learn_method.name,
          url: canonical_url_for(move_learn_method, :api_v3_move_learn_method_url)
        }
      end
    end
  end
end
