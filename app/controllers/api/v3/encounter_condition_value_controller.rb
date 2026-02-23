module Api
  module V3
    class EncounterConditionValueController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeEncounterConditionValue.order(:id),
          cache_key: "v3/encounter-condition-value#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        condition_value = find_by_id_or_name!(PokeEncounterConditionValue.all, params[:id])
        render_show_flow(record: condition_value, cache_key: "v3/encounter-condition-value#show")
      end

      private

      def summary_fields
        %i[id name url]
      end

      def detail_fields
        %i[id name encounter_condition_id is_default url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(condition_value, includes:, include_map:)
        {
          id: condition_value.id,
          name: condition_value.name,
          url: canonical_url_for(condition_value, :api_v3_encounter_condition_value_url)
        }
      end

      def detail_payload(condition_value, includes:, include_map:)
        {
          id: condition_value.id,
          name: condition_value.name,
          encounter_condition_id: condition_value.encounter_condition_id,
          is_default: condition_value.is_default,
          url: canonical_url_for(condition_value, :api_v3_encounter_condition_value_url)
        }
      end
    end
  end
end
