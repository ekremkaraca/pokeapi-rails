module Api
  module V3
    class EncounterMethodController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeEncounterMethod.order(:id),
          cache_key: "v3/encounter-method#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        method = PokeEncounterMethod.find(require_numeric_id!(params[:id]))
        render_show_flow(record: method, cache_key: "v3/encounter-method#show")
      end

      private

      def summary_fields
        %i[id name url]
      end

      def detail_fields
        %i[id name order url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(method, includes:, include_map:)
        {
          id: method.id,
          name: method.name,
          url: canonical_url_for(method, :api_v3_encounter_method_url)
        }
      end

      def detail_payload(method, includes:, include_map:)
        {
          id: method.id,
          name: method.name,
          order: method.sort_order,
          url: canonical_url_for(method, :api_v3_encounter_method_url)
        }
      end
    end
  end
end
