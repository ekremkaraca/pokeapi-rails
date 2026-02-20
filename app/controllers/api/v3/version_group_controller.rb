module Api
  module V3
    class VersionGroupController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeVersionGroup.order(:id),
          cache_key: "v3/version-group#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        version_group = PokeVersionGroup.find(require_numeric_id!(params[:id]))
        render_show_flow(record: version_group, cache_key: "v3/version-group#show")
      end

      private

      def summary_fields
        %i[id name url generation]
      end

      def detail_fields
        %i[id name generation_id sort_order url generation]
      end

      def summary_includes
        %i[generation]
      end

      def detail_includes
        %i[generation]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :generation, loader: :generation_by_version_group_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :generation, loader: :generation_by_version_group_id)
      end

      def summary_payload(version_group, includes:, include_map:)
        payload = {
          id: version_group.id,
          name: version_group.name,
          url: canonical_url_for(version_group, :api_v3_version_group_url)
        }
        payload[:generation] = include_map[version_group.id] if includes.include?(:generation)
        payload
      end

      def detail_payload(version_group, includes:, include_map:)
        payload = {
          id: version_group.id,
          name: version_group.name,
          generation_id: version_group.generation_id,
          sort_order: version_group.sort_order,
          url: canonical_url_for(version_group, :api_v3_version_group_url)
        }
        payload[:generation] = include_map[version_group.id] if includes.include?(:generation)
        payload
      end
    end
  end
end
