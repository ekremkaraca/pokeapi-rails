require "test_helper"
require "ostruct"
require "tempfile"
require Rails.root.join("lib/pokeapi/contract/openapi_drift")

class Pokeapi::Contract::OpenapiDriftTest < ActiveSupport::TestCase
  test "reports matched operations when source and rails routes align" do
    openapi = write_openapi(
      <<~YAML
        openapi: "3.0.0"
        paths:
          /api/v2/pokemon/:
            get: {}
          /api/v2/pokemon/{id}/:
            get: {}
          /api/v2/pokemon/{id}/encounters:
            get: {}
      YAML
    )

    routes = [
      route("GET", "/api/v2/pokemon(.:format)"),
      route("GET", "/api/v2/pokemon/:id(.:format)"),
      route("GET", "/api/v2/pokemon/:id/encounters(.:format)")
    ]

    result = Pokeapi::Contract::OpenapiDrift.new(
      source_openapi_path: openapi.path,
      rails_routes: routes
    ).run

    assert_equal true, result[:matches]
    assert_equal [], result[:missing_in_rails]
    assert_equal [], result[:extra_in_rails]
  end

  test "normalizes optional trailing slash and path parameter names" do
    openapi = write_openapi(
      <<~YAML
        openapi: "3.0.0"
        paths:
          /api/v2/pokemon/{pokemon_id}/encounters:
            get: {}
      YAML
    )

    routes = [
      route("GET", "/api/v2/pokemon/:id/encounters(/)(.:format)")
    ]

    result = Pokeapi::Contract::OpenapiDrift.new(
      source_openapi_path: openapi.path,
      rails_routes: routes
    ).run

    assert_equal true, result[:matches]
    assert_equal [], result[:missing_in_rails]
    assert_equal [], result[:extra_in_rails]
  end

  test "ignores api root route when source openapi omits it" do
    openapi = write_openapi(
      <<~YAML
        openapi: "3.0.0"
        paths:
          /api/v2/pokemon/:
            get: {}
      YAML
    )

    routes = [
      route("GET", "/api/v2(/)(.:format)"),
      route("GET", "/api/v2/pokemon(/)(.:format)")
    ]

    result = Pokeapi::Contract::OpenapiDrift.new(
      source_openapi_path: openapi.path,
      rails_routes: routes
    ).run

    assert_equal true, result[:matches]
    assert_equal [], result[:missing_in_rails]
    assert_equal [], result[:extra_in_rails]
  end

  test "reports missing and extra operations" do
    openapi = write_openapi(
      <<~YAML
        openapi: "3.0.0"
        paths:
          /api/v2/ability/:
            get: {}
          /api/v2/ability/{id}/:
            get: {}
      YAML
    )

    routes = [
      route("GET", "/api/v2/ability(.:format)"),
      route("GET", "/api/v2/ability/:id(.:format)"),
      route("GET", "/api/v2/custom-only(.:format)")
    ]

    result = Pokeapi::Contract::OpenapiDrift.new(
      source_openapi_path: openapi.path,
      rails_routes: routes
    ).run

    assert_equal false, result[:matches]
    assert_equal ["GET /api/v2/custom-only"], result[:extra_in_rails]
    assert_equal [], result[:missing_in_rails]
  end

  test "raises clear error for invalid openapi shape" do
    openapi = write_openapi(
      <<~YAML
        openapi: "3.0.0"
        paths:
          - invalid
      YAML
    )
    routes = [route("GET", "/api/v2/pokemon(.:format)")]

    error = assert_raises(ArgumentError) do
      Pokeapi::Contract::OpenapiDrift.new(
        source_openapi_path: openapi.path,
        rails_routes: routes
      ).run
    end

    assert_match(/invalid OpenAPI paths section/, error.message)
  end

  private

  def route(verb, path)
    OpenStruct.new(verb: verb, path: OpenStruct.new(spec: path))
  end

  def write_openapi(contents)
    file = Tempfile.new("openapi")
    file.write(contents)
    file.flush
    file
  end
end
