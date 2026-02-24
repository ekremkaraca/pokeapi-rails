require "test_helper"
require Rails.root.join("lib/pokeapi/logging/request_event")

module Pokeapi
  module Logging
    class RequestEventTest < ActiveSupport::TestCase
      Request = Struct.new(:request_id, :path, :query_parameters, :host, :remote_ip, :user_agent, :headers, keyword_init: true) do
        def ip
          remote_ip
        end

        def get_header(key)
          headers&.[](key)
        end
      end

      test "build returns compact structured request event" do
        payload = {
          request: Request.new(
            request_id: "req-123",
            path: "/api/v3/pokemon",
            query_parameters: { "limit" => "20", "offset" => "0" },
            host: "pokeapi.ekrem.dev",
            remote_ip: "203.0.113.2",
            user_agent: "curl/8.0"
          ),
          method: "GET",
          path: "/api/v3/pokemon?limit=20&offset=0",
          status: 200,
          controller: "Api::V3::PokemonController",
          action: "index",
          format: :json,
          headers: { "X-Query-Count" => "4", "Content-Length" => "1234" },
          db_runtime: 4.2123,
          view_runtime: 0.0,
          params: {
            "controller" => "api/v3/pokemon",
            "action" => "index",
            "limit" => "20"
          }
        }

        event = RequestEvent.build(
          payload: payload,
          started_at: 10.0,
          finished_at: 10.12345,
          slow_threshold_ms: 500
        )

        assert_equal "request", event[:event]
        assert_equal "req-123", event[:request_id]
        assert_equal "GET", event[:method]
        assert_equal "/api/v3/pokemon", event[:path]
        assert_equal %w[limit offset], event[:query_keys]
        assert_equal 200, event[:status]
        assert_equal "Api::V3::PokemonController", event[:controller]
        assert_equal "index", event[:action]
        assert_equal "json", event[:format]
        assert_equal "pokeapi.ekrem.dev", event[:host]
        assert_equal "203.0.113.2", event[:remote_ip]
        assert_equal "203.0.113.2", event[:client_ip]
        assert_equal Digest::SHA1.hexdigest("curl/8.0"), event[:ua_sha1]
        assert_equal 123.45, event[:duration_ms]
        assert_equal false, event[:slow]
        assert_equal 500.0, event[:slow_threshold_ms]
        assert_equal 4.21, event[:db_ms]
        assert_equal 0.0, event[:view_ms]
        assert_equal 4, event[:query_count]
        assert_equal 1234, event[:response_bytes]
        assert_equal({ "limit" => "20" }, event[:params])
      end

      test "build infers status 500 for exception payloads" do
        payload = {
          request: Request.new(
            request_id: "req-500",
            path: "/boom",
            query_parameters: {},
            host: "pokeapi.ekrem.dev",
            remote_ip: "203.0.113.9",
            user_agent: "Mozilla/5.0"
          ),
          method: "GET",
          path: "/boom",
          controller: "ErrorsController",
          action: "show",
          exception_object: RuntimeError.new("boom")
        }

        event = RequestEvent.build(
          payload: payload,
          started_at: 1.0,
          finished_at: 1.001,
          slow_threshold_ms: 500
        )

        assert_equal 500, event[:status]
        assert_equal "RuntimeError", event[:exception_class]
        assert_equal false, event[:slow]
      end

      test "build strips query string from payload path when request object is missing" do
        payload = {
          method: "GET",
          path: "/api/v3/pokemon?limit=20&offset=20",
          status: 200,
          controller: "Api::V3::PokemonController",
          action: "index",
          format: "*/*"
        }

        event = RequestEvent.build(
          payload: payload,
          started_at: 2.0,
          finished_at: 2.01,
          slow_threshold_ms: 5
        )

        assert_equal "/api/v3/pokemon", event[:path]
        assert_equal "unknown", event[:format]
        assert_equal true, event[:slow]
        refute event.key?(:query_keys)
      end

      test "build drops params for 404 fallback errors controller events" do
        payload = {
          request: Request.new(
            request_id: "req-404",
            path: "/.git/config",
            query_parameters: {},
            host: "pokeapi.ekrem.dev",
            remote_ip: "203.0.113.19",
            user_agent: "scanner"
          ),
          method: "GET",
          path: "/.git/config",
          status: 404,
          controller: "ErrorsController",
          action: "not_found",
          params: { "unmatched" => ".git/config" }
        }

        event = RequestEvent.build(
          payload: payload,
          started_at: 5.0,
          finished_at: 5.001
        )

        refute event.key?(:params)
      end

      test "build includes client_ip resolved from forwarded headers" do
        payload = {
          request: Request.new(
            request_id: "req-cf",
            path: "/",
            query_parameters: {},
            host: "pokeapi.ekrem.dev",
            remote_ip: "172.69.109.75",
            user_agent: "Mozilla/5.0",
            headers: { "HTTP_CF_CONNECTING_IP" => "198.51.100.42" }
          ),
          method: "GET",
          path: "/",
          status: 200,
          controller: "HomeController",
          action: "index"
        }

        event = RequestEvent.build(payload: payload, started_at: 1.0, finished_at: 1.01)

        assert_equal "172.69.109.75", event[:remote_ip]
        assert_equal "198.51.100.42", event[:client_ip]
      end

      test "build clamps db and view runtimes to request duration when payload values overflow" do
        payload = {
          request: Request.new(
            request_id: "req-overflow",
            path: "/api/v2/pokemon/ditto",
            query_parameters: {},
            host: "pokeapi.ekrem.dev",
            remote_ip: "203.0.113.29",
            user_agent: "curl/8.0"
          ),
          method: "GET",
          path: "/api/v2/pokemon/ditto",
          status: 200,
          controller: "Api::V2::PokemonController",
          action: "show",
          db_runtime: 1133.54,
          view_runtime: 9.91
        }

        event = RequestEvent.build(
          payload: payload,
          started_at: 100.0,
          finished_at: 101.08003
        )

        assert_equal 1080.03, event[:duration_ms]
        assert_equal 1080.03, event[:db_ms]
        assert_equal 9.91, event[:view_ms]
        assert_equal 1133.54, event[:db_ms_raw]
        assert_equal 9.91, event[:view_ms_raw]
        assert_equal true, event[:runtime_clamped]
      end
    end
  end
end
