module Api
  module V3
    class SuperContestEffectController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        super_contest_effect_table = PokeSuperContestEffect.arel_table
        render_index_flow(
          scope: PokeSuperContestEffect.order(:id),
          cache_key: "v3/super_contest_effect#index",
          sort_allowed: %i[id appeal],
          sort_default: "id",
          q_column: Arel.sql("CAST(#{super_contest_effect_table.name}.id AS TEXT)"),
          filter_allowed: []
        )
      end

      def show
        super_contest_effect = PokeSuperContestEffect.find(require_numeric_id!(params[:id]))
        render_show_flow(record: super_contest_effect, cache_key: "v3/super_contest_effect#show")
      end

      private

      def summary_fields
        %i[id appeal url]
      end

      def detail_fields
        %i[id appeal url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(super_contest_effect, includes:, include_map:)
        {
          id: super_contest_effect.id,
          appeal: super_contest_effect.appeal,
          url: canonical_url_for(super_contest_effect, :api_v3_super_contest_effect_url)
        }
      end

      def detail_payload(super_contest_effect, includes:, include_map:)
        {
          id: super_contest_effect.id,
          appeal: super_contest_effect.appeal,
          url: canonical_url_for(super_contest_effect, :api_v3_super_contest_effect_url)
        }
      end
    end
  end
end
