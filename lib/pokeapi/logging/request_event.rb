module Pokeapi
  module Logging
    class RequestEvent
      class << self
        def build(payload:, started_at:, finished_at:)
          request = payload[:request]
          params = payload[:params].is_a?(Hash) ? payload[:params].except("controller", "action", "format") : {}
          exception = payload[:exception_object]
          status = payload[:status] || (exception ? 500 : nil)

          {
            event: "request",
            request_id: request&.request_id,
            method: payload[:method],
            path: payload[:path],
            status: status,
            controller: payload[:controller],
            action: payload[:action],
            format: payload[:format].to_s.presence,
            duration_ms: ((finished_at - started_at) * 1000.0).round(2),
            db_ms: payload[:db_runtime].to_f.round(2),
            view_ms: payload[:view_runtime].to_f.round(2),
            params: params.presence,
            exception_class: exception&.class&.name
          }.compact
        end
      end
    end
  end
end
