module Api
  module V2
    class BaseController < ActionController::API
      include Api::RateLimitHeaders
      include Api::ObservabilityHeaders
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      before_action :force_json_format
      around_action :set_observability_headers

      private

      def force_json_format
        request.format = :json
      end

      def render_not_found
        head :not_found
      end

      def stale_collection?(scope:, cache_key:, variation: {})
        last_modified = scope.maximum(:updated_at)
        normalized_variation = variation.to_h.sort.to_h

        stale?(
          etag: [ cache_key, normalized_variation, scope.count, last_modified&.utc&.to_i ],
          last_modified: last_modified,
          public: true
        )
      end

      def stale_resource?(record:, cache_key:, variation: {})
        normalized_variation = variation.to_h.sort.to_h

        stale?(
          etag: [ cache_key, normalized_variation, record.cache_key_with_version ],
          last_modified: record.updated_at,
          public: true
        )
      end
    end
  end
end
