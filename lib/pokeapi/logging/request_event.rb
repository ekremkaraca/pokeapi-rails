require "digest/sha1"

module Pokeapi
  module Logging
    class RequestEvent
      class << self
        def build(payload:, started_at:, finished_at:)
          request = payload[:request]
          params = payload[:params].is_a?(Hash) ? payload[:params].except("controller", "action", "format") : {}
          exception = payload[:exception_object]
          status = payload[:status] || (exception ? 500 : nil)
          query_keys = request&.query_parameters&.keys&.map(&:to_s)&.sort
          normalized_path = request&.path.presence || payload[:path].to_s.split("?").first
          compact_params = compact_params_for(params: params, status: status, controller: payload[:controller])
          user_agent = request&.user_agent.to_s

          {
            event: "request",
            request_id: request&.request_id,
            method: payload[:method],
            path: normalized_path,
            query_keys: query_keys.presence,
            status: status,
            controller: payload[:controller],
            action: payload[:action],
            format: payload[:format].to_s.presence,
            host: request&.host,
            remote_ip: request&.remote_ip,
            ua_sha1: user_agent.present? ? Digest::SHA1.hexdigest(user_agent) : nil,
            duration_ms: ((finished_at - started_at) * 1000.0).round(2),
            db_ms: payload[:db_runtime].to_f.round(2),
            view_ms: payload[:view_runtime].to_f.round(2),
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
      end
    end
  end
end
