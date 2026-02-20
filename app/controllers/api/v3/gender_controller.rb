module Api
  module V3
    class GenderController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeGender.order(:id),
          cache_key: "v3/gender#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        gender = PokeGender.find(require_numeric_id!(params[:id]))
        render_show_flow(record: gender, cache_key: "v3/gender#show")
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

      def summary_payload(gender, includes:, include_map:)
        {
          id: gender.id,
          name: gender.name,
          url: canonical_url_for(gender, :api_v3_gender_url)
        }
      end

      def detail_payload(gender, includes:, include_map:)
        {
          id: gender.id,
          name: gender.name,
          url: canonical_url_for(gender, :api_v3_gender_url)
        }
      end
    end
  end
end
