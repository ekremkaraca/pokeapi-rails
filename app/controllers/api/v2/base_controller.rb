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
        render json: { detail: "Not found." }, status: :not_found
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

      def cached_json_payload(cache_key, expires_in: show_cache_ttl, race_condition_ttl: 5.seconds)
        return yield if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)

        Rails.cache.fetch(cache_key, expires_in: expires_in, race_condition_ttl: race_condition_ttl) { yield }
      end

      def show_cache_ttl
        ENV.fetch("API_V2_SHOW_CACHE_TTL_SECONDS", "60").to_i.seconds
      end
    end
  end
end
