require "digest/sha1"
require Rails.root.join("lib/pokeapi/network/client_ip")

module Pokeapi
  module Logging
    class RequestEvent
      class << self
        def build(payload:, started_at:, finished_at:, slow_threshold_ms: nil)
          request = payload[:request]
          params = payload[:params].is_a?(Hash) ? payload[:params].except("controller", "action", "format") : {}
          headers = payload[:headers]
          exception = payload[:exception_object]
          status = payload[:status] || (exception ? 500 : nil)
          query_keys = request&.query_parameters&.keys&.map(&:to_s)&.sort
          normalized_path = request&.path.presence || payload[:path].to_s.split("?").first
          compact_params = compact_params_for(params: params, status: status, controller: payload[:controller])
          user_agent = request&.user_agent.to_s
          duration_ms = ((finished_at - started_at) * 1000.0).round(2)
          slow_threshold_value = slow_threshold_ms&.to_f
          slow = slow_threshold_value ? duration_ms >= slow_threshold_value : nil
          runtime_values = normalized_runtime_values(
            duration_ms: duration_ms,
            db_runtime_ms: payload[:db_runtime].to_f,
            view_runtime_ms: payload[:view_runtime].to_f
          )

          {
            event: "request",
            request_id: request&.request_id,
            method: payload[:method],
            path: normalized_path,
            query_keys: query_keys.presence,
            status: status,
            controller: payload[:controller],
            action: payload[:action],
            format: normalize_format(payload[:format]),
            host: request&.host,
            remote_ip: request&.remote_ip,
            client_ip: Pokeapi::Network::ClientIp.from_request(request),
            ua_sha1: user_agent.present? ? Digest::SHA1.hexdigest(user_agent) : nil,
            duration_ms: duration_ms,
            slow: slow,
            slow_threshold_ms: slow_threshold_value,
            db_ms: runtime_values[:db_ms],
            view_ms: runtime_values[:view_ms],
            db_ms_raw: runtime_values[:db_ms_raw],
            view_ms_raw: runtime_values[:view_ms_raw],
            runtime_clamped: runtime_values[:runtime_clamped],
            query_count: parse_integer_header(headers, "X-Query-Count"),
            response_bytes: parse_integer_header(headers, "Content-Length"),
            params: compact_params.presence,
            exception_class: exception&.class&.name
          }.compact
        end

        private

        def compact_params_for(params:, status:, controller:)
          return {} if params.blank?
          return {} if controller == "ErrorsController" && status.to_i == 404

          params
        end

        def normalize_format(format)
          value = format.to_s.strip
          return nil if value.empty?
          return "unknown" if value == "*/*"

          value.downcase
        end

        def parse_integer_header(headers, key)
          return nil unless headers.respond_to?(:[])

          raw = headers[key].to_s.strip
          return nil unless /\A\d+\z/.match?(raw)

          raw.to_i
        end

        def normalized_runtime_values(duration_ms:, db_runtime_ms:, view_runtime_ms:)
          total = duration_ms.to_f
          db_raw = db_runtime_ms.round(2)
          view_raw = view_runtime_ms.round(2)

          # Keep timing fields physically consistent in logs (sub-runtime should not exceed wall time).
          db = db_raw.clamp(0.0, total).round(2)
          view = view_raw.clamp(0.0, total).round(2)
          clamped = (db != db_raw) || (view != view_raw)

          {
            db_ms: db,
            view_ms: view,
            db_ms_raw: clamped ? db_raw : nil,
            view_ms_raw: clamped ? view_raw : nil,
            runtime_clamped: clamped ? true : nil
          }
        end
      end
    end
  end
end
