require "test_helper"
require Rails.root.join("lib/pokeapi/logging/request_event")

module Pokeapi
  module Logging
    class RequestEventTest < ActiveSupport::TestCase
      Request = Struct.new(:request_id)

      test "build returns compact structured request event" do
        payload = {
          request: Request.new("req-123"),
          method: "GET",
          path: "/api/v3/pokemon",
          status: 200,
          controller: "Api::V3::PokemonController",
          action: "index",
          format: :json,
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
          finished_at: 10.12345
        )

        assert_equal "request", event[:event]
        assert_equal "req-123", event[:request_id]
        assert_equal "GET", event[:method]
        assert_equal "/api/v3/pokemon", event[:path]
        assert_equal 200, event[:status]
        assert_equal "Api::V3::PokemonController", event[:controller]
        assert_equal "index", event[:action]
        assert_equal "json", event[:format]
        assert_equal 123.45, event[:duration_ms]
        assert_equal 4.21, event[:db_ms]
        assert_equal 0.0, event[:view_ms]
        assert_equal({ "limit" => "20" }, event[:params])
      end

      test "build infers status 500 for exception payloads" do
        payload = {
          request: Request.new("req-500"),
          method: "GET",
          path: "/boom",
          controller: "ErrorsController",
          action: "show",
          exception_object: RuntimeError.new("boom")
        }

        event = RequestEvent.build(
          payload: payload,
          started_at: 1.0,
          finished_at: 1.001
        )

        assert_equal 500, event[:status]
        assert_equal "RuntimeError", event[:exception_class]
      end
    end
  end
end
