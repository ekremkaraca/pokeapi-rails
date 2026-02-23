module Api
  module V3
    class LanguageController < BaseController
      include Paginatable
      include QueryFilterable
      include FieldSelectable
      include IncludeExpandable
      include IncludeLoaders
      include EndpointFlow
      include Sortable

      def index
        render_index_flow(
          scope: PokeLanguage.order(:id),
          cache_key: "v3/language#index",
          sort_allowed: %i[id name],
          sort_default: "id"
        )
      end

      def show
        language = find_by_id_or_name!(PokeLanguage.all, params[:id])
        render_show_flow(record: language, cache_key: "v3/language#show")
      end

      private

      def summary_fields
        %i[id name official url]
      end

      def detail_fields
        %i[id name official iso639 iso3166 sort_order url]
      end

      def summary_includes
        []
      end

      def detail_includes
        []
      end

      def summary_payload(language, includes:, include_map:)
        {
          id: language.id,
          name: language.name,
          official: language.official,
          url: canonical_url_for(language, :api_v3_language_url)
        }
      end

      def detail_payload(language, includes:, include_map:)
        {
          id: language.id,
          name: language.name,
          official: language.official,
          iso639: language.iso639,
          iso3166: language.iso3166,
          sort_order: language.sort_order,
          url: canonical_url_for(language, :api_v3_language_url)
        }
      end
    end
  end
end
