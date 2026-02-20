module Api
  module V3
    class MoveDamageClassController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeMoveDamageClass.order(:id),
          cache_key: "v3/move_damage_class#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        move_damage_class = PokeMoveDamageClass.find(require_numeric_id!(params[:id]))
        render_show_flow(record: move_damage_class, cache_key: "v3/move_damage_class#show")
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

      def summary_payload(move_damage_class, includes:, include_map:)
        {
          id: move_damage_class.id,
          name: move_damage_class.name,
          url: canonical_url_for(move_damage_class, :api_v3_move_damage_class_url)
        }
      end

      def detail_payload(move_damage_class, includes:, include_map:)
        {
          id: move_damage_class.id,
          name: move_damage_class.name,
          url: canonical_url_for(move_damage_class, :api_v3_move_damage_class_url)
        }
      end
    end
  end
end
