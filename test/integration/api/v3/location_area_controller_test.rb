require "test_helper"

class Api::V3::LocationAreaControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeLocationArea.delete_all
    PokeLocation.delete_all
    PokeRegion.delete_all

    sinnoh = PokeRegion.create!(name: "sinnoh")
    location = PokeLocation.create!(name: "oreburgh-mine", region_id: sinnoh.id)

    [
      { name: "oreburgh-mine-1f", location_id: location.id, game_index: 1 },
      { name: "oreburgh-mine-b1f", location_id: location.id, game_index: 2 },
      { name: "oreburgh-mine-b2f", location_id: location.id, game_index: 3 }
    ].each do |attrs|
      PokeLocationArea.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/location-area", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[game_index id location_id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/location-area/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/location-area", params: { q: "b1f" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "oreburgh-mine-b1f", payload.dig("results", 0, "name")
  end

  test "list supports filter by name" do
    get "/api/v3/location-area", params: { filter: { name: "oreburgh-mine-1f" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "oreburgh-mine-1f", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/location-area", params: { q: "b", filter: { name: "oreburgh-mine-b2f" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "oreburgh-mine-b2f", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/location-area", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "oreburgh-mine-b2f", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/location-area", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include location" do
    get "/api/v3/location-area", params: { filter: { name: "oreburgh-mine-1f" }, include: "location" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "oreburgh-mine-1f", result["name"]
    assert_equal "oreburgh-mine", result.dig("location", "name")
    assert_match(%r{/api/v3/location/\d+/$}, result.dig("location", "url"))
  end

  test "show returns location area payload with standardized keys" do
    area = PokeLocationArea.find_by!(name: "oreburgh-mine-1f")

    get "/api/v3/location-area/#{area.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[game_index id location_id name url], payload.keys.sort
    assert_equal area.id, payload["id"]
    assert_equal "oreburgh-mine-1f", payload["name"]
    assert_match(%r{/api/v3/location-area/#{area.id}/$}, payload["url"])
  end

  test "show supports include location" do
    area = PokeLocationArea.find_by!(name: "oreburgh-mine-b1f")

    get "/api/v3/location-area/#{area.id}", params: { include: "location" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "oreburgh-mine", payload.dig("location", "name")
    assert_match(%r{/api/v3/location/\d+/$}, payload.dig("location", "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/location-area/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_not_found_error_envelope(payload)
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/location-area", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "fields", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/location-area", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "include", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/location-area", params: { sort: "game_index" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "sort", invalid_values: [ "game_index" ])
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/location-area", params: { filter: { location_id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "filter", invalid_values: [ "location_id" ])
  end

  test "list and show accept trailing slash" do
    area = PokeLocationArea.find_by!(name: "oreburgh-mine-1f")

    get "/api/v3/location-area/"
    assert_response :success

    get "/api/v3/location-area/#{area.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/location-area", params: { limit: 2, offset: 0, q: "b" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/location-area", params: { limit: 2, offset: 0, q: "b" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    area = PokeLocationArea.find_by!(name: "oreburgh-mine-1f")

    get "/api/v3/location-area/#{area.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/location-area/#{area.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "list etag varies by include parameter" do
    get "/api/v3/location-area", params: { q: "b" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/location-area", params: { q: "b", include: "location" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    area = PokeLocationArea.find_by!(name: "oreburgh-mine-1f")

    get "/api/v3/location-area/#{area.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/location-area/#{area.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
