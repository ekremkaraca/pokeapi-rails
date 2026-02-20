module Api
  module V2
    class VersionController < BaseController
      include NameSearchableResource

      MODEL_CLASS = PokeVersion
      RESOURCE_URL_HELPER = :api_v2_version_url
    end
  end
end
