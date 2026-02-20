module Api
  module V3
    class MoveCategoryController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeMoveMetaCategory.order(:id),
          cache_key: "v3/move_category#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        move_category = PokeMoveMetaCategory.find(require_numeric_id!(params[:id]))
        render_show_flow(record: move_category, cache_key: "v3/move_category#show")
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

      def summary_payload(move_category, includes:, include_map:)
        {
          id: move_category.id,
          name: move_category.name,
          url: canonical_url_for(move_category, :api_v3_move_category_url)
        }
      end

      def detail_payload(move_category, includes:, include_map:)
        {
          id: move_category.id,
          name: move_category.name,
          url: canonical_url_for(move_category, :api_v3_move_category_url)
        }
      end
    end
  end
end
