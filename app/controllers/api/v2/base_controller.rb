module Api
  module V2
    class BaseController < ActionController::API
      include Api::RateLimitHeaders
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

      def set_observability_headers
        query_count = 0
        started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        callback = lambda do |_name, _start, _finish, _id, payload|
          next if payload[:cached]
          next if payload[:name] == "SCHEMA"

          sql = payload[:sql].to_s
          next if sql.start_with?("BEGIN", "COMMIT", "ROLLBACK", "SAVEPOINT", "RELEASE SAVEPOINT")

          query_count += 1
        end

        ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
          yield
        end
      ensure
        elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000.0).round(2)
        response.set_header("X-Query-Count", query_count.to_s)
        response.set_header("X-Response-Time-Ms", elapsed_ms.to_s)
      end
    end
  end
end
