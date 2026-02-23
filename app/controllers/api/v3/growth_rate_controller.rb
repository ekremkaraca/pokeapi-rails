module Api
  module V3
    class GrowthRateController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeGrowthRate.order(:id),
          cache_key: "v3/growth-rate#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        growth_rate = find_by_id_or_name!(PokeGrowthRate.all, params[:id])
        render_show_flow(record: growth_rate, cache_key: "v3/growth-rate#show")
      end

      private

      def summary_fields
        %i[id name url]
      end

      def detail_fields
        %i[id name formula url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(growth_rate, includes:, include_map:)
        {
          id: growth_rate.id,
          name: growth_rate.name,
          url: canonical_url_for(growth_rate, :api_v3_growth_rate_url)
        }
      end

      def detail_payload(growth_rate, includes:, include_map:)
        {
          id: growth_rate.id,
          name: growth_rate.name,
          formula: growth_rate.formula,
          url: canonical_url_for(growth_rate, :api_v3_growth_rate_url)
        }
      end
    end
  end
end
