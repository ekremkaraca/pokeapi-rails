require "test_helper"

class Api::V3::LocationControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeLocation.delete_all
    PokeRegion.delete_all

    kanto = PokeRegion.create!(name: "kanto")
    johto = PokeRegion.create!(name: "johto")

    [
      { name: "pallet-town", region_id: kanto.id },
      { name: "cerulean-city", region_id: kanto.id },
      { name: "new-bark-town", region_id: johto.id }
    ].each do |attrs|
      PokeLocation.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/location", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[id name region_id url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/location/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/location", params: { q: "town" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 2, payload["count"]
  end

  test "list supports filter by name" do
    get "/api/v3/location", params: { filter: { name: "cerulean-city" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "cerulean-city", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/location", params: { q: "town", filter: { name: "pallet-town" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "pallet-town", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/location", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "pallet-town", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/location", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include region" do
    get "/api/v3/location", params: { filter: { name: "pallet-town" }, include: "region" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "pallet-town", result["name"]
    assert_equal "kanto", result.dig("region", "name")
    assert_match(%r{/api/v3/region/\d+/$}, result.dig("region", "url"))
  end

  test "show returns location payload with standardized keys" do
    location = PokeLocation.find_by!(name: "new-bark-town")

    get "/api/v3/location/#{location.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name region_id url], payload.keys.sort
    assert_equal location.id, payload["id"]
    assert_equal "new-bark-town", payload["name"]
    assert_match(%r{/api/v3/location/#{location.id}/$}, payload["url"])
  end

  test "show supports include region" do
    location = PokeLocation.find_by!(name: "new-bark-town")

    get "/api/v3/location/#{location.id}", params: { include: "region" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "johto", payload.dig("region", "name")
    assert_match(%r{/api/v3/region/\d+/$}, payload.dig("region", "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/location/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/location", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/location", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/location", params: { sort: "region_id" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["region_id"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/location", params: { filter: { region_id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["region_id"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    location = PokeLocation.find_by!(name: "new-bark-town")

    get "/api/v3/location/"
    assert_response :success

    get "/api/v3/location/#{location.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/location", params: { limit: 2, offset: 0, q: "town" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/location", params: { limit: 2, offset: 0, q: "town" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    location = PokeLocation.find_by!(name: "new-bark-town")

    get "/api/v3/location/#{location.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/location/#{location.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by include parameter" do
    get "/api/v3/location", params: { q: "town" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/location", params: { q: "town", include: "region" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    location = PokeLocation.find_by!(name: "new-bark-town")

    get "/api/v3/location/#{location.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/location/#{location.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
