module Api
  module V2
    class LanguageController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeLanguage
      RESOURCE_URL_HELPER = :api_v2_language_url

      private

      def detail_extras(language)
        {
          official: language.official
        }
      end
    end
  end
end
