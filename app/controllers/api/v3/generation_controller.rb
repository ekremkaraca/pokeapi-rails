module Api
  module V3
    class GenerationController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeGeneration.order(:id),
          cache_key: "v3/generation#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        generation = PokeGeneration.find(require_numeric_id!(params[:id]))
        render_show_flow(record: generation, cache_key: "v3/generation#show")
      end

      private

      def summary_fields
        %i[id name url main_region]
      end

      def detail_fields
        %i[id name main_region_id url main_region]
      end

      def summary_includes
        %i[main_region]
      end

      def detail_includes
        %i[main_region]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :main_region, loader: :main_region_by_generation_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :main_region, loader: :main_region_by_generation_id)
      end

      def summary_payload(generation, includes:, include_map:)
        payload = {
          id: generation.id,
          name: generation.name,
          url: canonical_url_for(generation, :api_v3_generation_url)
        }
        payload[:main_region] = include_map[generation.id] if includes.include?(:main_region)
        payload
      end

      def detail_payload(generation, includes:, include_map:)
        payload = {
          id: generation.id,
          name: generation.name,
          main_region_id: generation.main_region_id,
          url: canonical_url_for(generation, :api_v3_generation_url)
        }
        payload[:main_region] = include_map[generation.id] if includes.include?(:main_region)
        payload
      end
    end
  end
end
