module Api
  module V3
    class ContestTypeController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeContestType.order(:id),
          cache_key: "v3/contest_type#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        contest_type = find_by_id_or_name!(PokeContestType.all, params[:id])
        render_show_flow(record: contest_type, cache_key: "v3/contest_type#show")
      end

      private

      def summary_fields
        %i[id name url berry_flavors]
      end

      def detail_fields
        %i[id name url berry_flavors]
      end

      def summary_includes
        %i[berry_flavors]
      end

      def detail_includes
        %i[berry_flavors]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(
          records: records,
          includes: includes,
          include_key: :berry_flavors,
          loader: :berry_flavors_by_contest_type_id
        )
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(
          record: record,
          includes: includes,
          include_key: :berry_flavors,
          loader: :berry_flavors_by_contest_type_id
        )
      end

      def summary_payload(contest_type, includes:, include_map:)
        payload = {
          id: contest_type.id,
          name: contest_type.name,
          url: canonical_url_for(contest_type, :api_v3_contest_type_url)
        }
        payload[:berry_flavors] = include_map[contest_type.id] if includes.include?(:berry_flavors)
        payload
      end

      def detail_payload(contest_type, includes:, include_map:)
        payload = {
          id: contest_type.id,
          name: contest_type.name,
          url: canonical_url_for(contest_type, :api_v3_contest_type_url)
        }
        payload[:berry_flavors] = include_map[contest_type.id] if includes.include?(:berry_flavors)
        payload
      end
    end
  end
end
