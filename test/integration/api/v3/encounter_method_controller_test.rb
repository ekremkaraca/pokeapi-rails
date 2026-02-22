require "test_helper"

class Api::V3::EncounterMethodControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeEncounterMethod.delete_all

    [
      { name: "walk", sort_order: 1 },
      { name: "old-rod", sort_order: 10 },
      { name: "good-rod", sort_order: 11 },
      { name: "super-rod", sort_order: 12 },
      { name: "surf", sort_order: 14 }
    ].each do |attrs|
      PokeEncounterMethod.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/encounter-method", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/encounter-method/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/encounter-method", params: { q: "rod" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
  end

  test "list supports filter by name" do
    get "/api/v3/encounter-method", params: { filter: { name: "walk" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "walk", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/encounter-method", params: { q: "rod", filter: { name: "good-rod" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "good-rod", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/encounter-method", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "walk", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/encounter-method", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns encounter method payload with standardized keys" do
    method = PokeEncounterMethod.find_by!(name: "walk")

    get "/api/v3/encounter-method/#{method.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name order url], payload.keys.sort
    assert_equal method.id, payload["id"]
    assert_equal "walk", payload["name"]
    assert_equal 1, payload["order"]
    assert_match(%r{/api/v3/encounter-method/#{method.id}/$}, payload["url"])
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/encounter-method/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_not_found_error_envelope(payload)
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/encounter-method", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "fields", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/encounter-method", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "include", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/encounter-method", params: { sort: "order" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "sort", invalid_values: [ "order" ])
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/encounter-method", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "filter", invalid_values: [ "id" ])
  end

  test "list and show accept trailing slash" do
    method = PokeEncounterMethod.find_by!(name: "walk")

    get "/api/v3/encounter-method/"
    assert_response :success

    get "/api/v3/encounter-method/#{method.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/encounter-method", params: { limit: 2, offset: 0, q: "rod" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/encounter-method", params: { limit: 2, offset: 0, q: "rod" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    method = PokeEncounterMethod.find_by!(name: "walk")

    get "/api/v3/encounter-method/#{method.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/encounter-method/#{method.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/encounter-method", params: { limit: 2, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/encounter-method", params: { limit: 2, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    method = PokeEncounterMethod.find_by!(name: "walk")

    get "/api/v3/encounter-method/#{method.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/encounter-method/#{method.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
