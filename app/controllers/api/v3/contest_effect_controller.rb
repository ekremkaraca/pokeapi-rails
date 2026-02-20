module Api
  module V3
    class ContestEffectController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeContestEffect.order(:id),
          cache_key: "v3/contest_effect#index",
          sort_allowed: %i[id appeal jam],
          sort_default: "id",
          q_column: "CONCAT('contest-effect-', contest_effect.id)"
        )
      end

      def show
        contest_effect = PokeContestEffect.find(require_numeric_id!(params[:id]))
        render_show_flow(record: contest_effect, cache_key: "v3/contest_effect#show")
      end

      private

      def summary_fields
        %i[id name appeal jam url moves]
      end

      def detail_fields
        %i[id name appeal jam url moves]
      end

      def summary_includes
        %i[moves]
      end

      def detail_includes
        %i[moves]
      end

      def summary_include_map(records:, includes:)
        include_map_for_collection(
          records: records,
          includes: includes,
          include_key: :moves,
          loader: :moves_by_contest_effect_id
        )
      end

      def detail_include_map(record:, includes:)
        include_map_for_resource(
          record: record,
          includes: includes,
          include_key: :moves,
          loader: :moves_by_contest_effect_id
        )
      end

      def summary_payload(contest_effect, includes:, include_map:)
        payload = {
          id: contest_effect.id,
          name: synthetic_name_for(contest_effect.id),
          appeal: contest_effect.appeal,
          jam: contest_effect.jam,
          url: canonical_url_for(contest_effect, :api_v3_contest_effect_url)
        }
        payload[:moves] = include_map[contest_effect.id] if includes.include?(:moves)
        payload
      end

      def detail_payload(contest_effect, includes:, include_map:)
        payload = {
          id: contest_effect.id,
          name: synthetic_name_for(contest_effect.id),
          appeal: contest_effect.appeal,
          jam: contest_effect.jam,
          url: canonical_url_for(contest_effect, :api_v3_contest_effect_url)
        }
        payload[:moves] = include_map[contest_effect.id] if includes.include?(:moves)
        payload
      end

      def apply_filter_params(scope, allowed:)
        filters = normalized_filter_params(allowed: allowed)

        filters.reduce(scope) do |current_scope, (field, value)|
          if field == "name"
            current_scope.where("CONCAT('contest-effect-', contest_effect.id) ILIKE ?", value)
          else
            current_scope.where("#{field} ILIKE ?", value)
          end
        end
      end

      def synthetic_name_for(id)
        "contest-effect-#{id}"
      end
    end
  end
end
