module Api
  module V3
    class BaseController < ActionController::API
      include Api::RateLimitHeaders
      include Api::ObservabilityHeaders
      class InvalidQueryParameterError < StandardError
        attr_reader :details

        def initialize(details = {})
          @details = details
          super("Invalid query parameter")
        end
      end

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from InvalidQueryParameterError, with: :render_invalid_query
      before_action :force_json_format
      before_action :set_v3_stability_header
      around_action :set_observability_headers

      private

      def force_json_format
        request.format = :json
      end

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

      def require_numeric_id!(value)
        raw = value.to_s.strip
        raise ActiveRecord::RecordNotFound unless /\A\d+\z/.match?(raw)

        raw.to_i
      end

      def find_by_id_or_name!(scope, value, name_column: :name, allow_signed_id: false)
        raw = value.to_s.strip
        raise ActiveRecord::RecordNotFound if raw.empty?

        # Match integer IDs based on allow_signed_id parameter
        id_pattern = allow_signed_id ? /\A-?\d+\z/ : /\A\d+\z/
        return scope.find(raw.to_i) if id_pattern.match?(raw)

        table = scope.klass.arel_table
        normalized_name = raw.downcase
        indexed_match = scope.where(name_column => normalized_name).order(scope.klass.primary_key => :asc).first
        return indexed_match if indexed_match

        lower_name = Arel::Nodes::NamedFunction.new("LOWER", [ table[name_column] ])

        scope.where(lower_name.eq(normalized_name)).order(scope.klass.primary_key => :asc).first!
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
