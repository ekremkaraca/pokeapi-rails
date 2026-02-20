module Api
  module V3
    class VersionController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeVersion.order(:id),
          cache_key: "v3/version#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        version = PokeVersion.find(require_numeric_id!(params[:id]))
        render_show_flow(record: version, cache_key: "v3/version#show")
      end

      private

      def summary_fields
        %i[id name url version_group]
      end

      def detail_fields
        %i[id name version_group_id url version_group]
      end

      def summary_includes
        %i[version_group]
      end

      def detail_includes
        %i[version_group]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(records: records, includes: includes, include_key: :version_group, loader: :version_group_by_version_id)
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(record: record, includes: includes, include_key: :version_group, loader: :version_group_by_version_id)
      end

      def summary_payload(version, includes:, include_map:)
        payload = {
          id: version.id,
          name: version.name,
          url: canonical_url_for(version, :api_v3_version_url)
        }
        payload[:version_group] = include_map[version.id] if includes.include?(:version_group)
        payload
      end

      def detail_payload(version, includes:, include_map:)
        payload = {
          id: version.id,
          name: version.name,
          version_group_id: version.version_group_id,
          url: canonical_url_for(version, :api_v3_version_url)
        }
        payload[:version_group] = include_map[version.id] if includes.include?(:version_group)
        payload
      end
    end
  end
end
