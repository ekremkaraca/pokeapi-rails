module Api
  module V3
    class MoveAilmentController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeMoveAilment.order(:id),
          cache_key: "v3/move_ailment#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        ailment = PokeMoveAilment.find(require_signed_id!(params[:id]))
        render_show_flow(record: ailment, cache_key: "v3/move_ailment#show")
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

      def summary_payload(ailment, includes:, include_map:)
        {
          id: ailment.id,
          name: ailment.name,
          url: canonical_url_for(ailment, :api_v3_move_ailment_url)
        }
      end

      def detail_payload(ailment, includes:, include_map:)
        {
          id: ailment.id,
          name: ailment.name,
          url: canonical_url_for(ailment, :api_v3_move_ailment_url)
        }
      end

      def require_signed_id!(value)
        raw = value.to_s.strip
        raise ActiveRecord::RecordNotFound unless /\A-?\d+\z/.match?(raw)

        raw.to_i
      end
    end
  end
end
