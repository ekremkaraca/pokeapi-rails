module Api
  module V3
    class BaseController < ActionController::API
      class InvalidQueryParameterError < StandardError
        attr_reader :details

        def initialize(details = {})
          @details = details
          super("Invalid query parameter")
        end
      end

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from InvalidQueryParameterError, with: :render_invalid_query
      before_action :set_v3_stability_header
      around_action :set_observability_headers

      private

      def render_error(code:, message:, status:, details: {})
        render json: {
          error: {
            code: code,
            message: message,
            details: details,
            request_id: request.request_id
          }
        }, status: status
      end

      def render_not_found
        render_error(code: "not_found", message: "Resource not found", status: :not_found)
      end

      def render_invalid_query(error)
        render_error(code: "invalid_query", message: "Invalid query parameter", status: :bad_request, details: error.details)
      end

      def set_v3_stability_header
        response.set_header("X-API-Stability", "experimental")
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

      def require_numeric_id!(value)
        raw = value.to_s.strip
        raise ActiveRecord::RecordNotFound unless /\A\d+\z/.match?(raw)

        raw.to_i
      end

      def stale_collection?(scope:, cache_key:, variation: {})
        last_modified = scope.maximum(:updated_at)
        normalized_variation = variation.to_h.sort.to_h

        stale?(
          etag: [cache_key, normalized_variation, scope.count, last_modified&.utc&.to_i],
          last_modified: last_modified,
          public: true
        )
      end

      def stale_resource?(record:, cache_key:, variation: {})
        normalized_variation = variation.to_h.sort.to_h

        stale?(
          etag: [cache_key, normalized_variation, record.cache_key_with_version],
          last_modified: record.updated_at,
          public: true
        )
      end
    end
  end
end
