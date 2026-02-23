module Api
  module V3
    class EvolutionTriggerController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeEvolutionTrigger.order(:id),
          cache_key: "v3/evolution-trigger#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        evolution_trigger = find_by_id_or_name!(PokeEvolutionTrigger.all, params[:id])
        render_show_flow(record: evolution_trigger, cache_key: "v3/evolution-trigger#show")
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

      def summary_payload(evolution_trigger, includes:, include_map:)
        {
          id: evolution_trigger.id,
          name: evolution_trigger.name,
          url: canonical_url_for(evolution_trigger, :api_v3_evolution_trigger_url)
        }
      end

      def detail_payload(evolution_trigger, includes:, include_map:)
        {
          id: evolution_trigger.id,
          name: evolution_trigger.name,
          url: canonical_url_for(evolution_trigger, :api_v3_evolution_trigger_url)
        }
      end
    end
  end
end
