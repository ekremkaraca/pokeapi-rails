module Api
  module V3
    class EncounterConditionController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeEncounterCondition.order(:id),
          cache_key: "v3/encounter-condition#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        condition = find_by_id_or_name!(PokeEncounterCondition.all, params[:id])
        render_show_flow(record: condition, cache_key: "v3/encounter-condition#show")
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

      def summary_payload(condition, includes:, include_map:)
        {
          id: condition.id,
          name: condition.name,
          url: canonical_url_for(condition, :api_v3_encounter_condition_url)
        }
      end

      def detail_payload(condition, includes:, include_map:)
        {
          id: condition.id,
          name: condition.name,
          url: canonical_url_for(condition, :api_v3_encounter_condition_url)
        }
      end
    end
  end
end
