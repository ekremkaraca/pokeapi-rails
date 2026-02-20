require "test_helper"

class Api::V3::RegionControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeGeneration.delete_all
    PokeRegion.delete_all

    kanto = PokeRegion.create!(name: "kanto")
    johto = PokeRegion.create!(name: "johto")
    hoenn = PokeRegion.create!(name: "hoenn")
    sinnoh = PokeRegion.create!(name: "sinnoh")
    unova = PokeRegion.create!(name: "unova")

    [
      { name: "generation-i", main_region_id: kanto.id },
      { name: "generation-ii", main_region_id: johto.id },
      { name: "generation-iii", main_region_id: hoenn.id },
      { name: "generation-iv", main_region_id: sinnoh.id },
      { name: "generation-v", main_region_id: unova.id }
    ].each do |attrs|
      PokeGeneration.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/region", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/region/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/region", params: { q: "hoe" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "hoenn", payload["results"].first["name"]
  end

  test "list supports filter by name" do
    get "/api/v3/region", params: { filter: { name: "kanto" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "kanto", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/region", params: { q: "kan", filter: { name: "kanto" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "kanto", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/region", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "unova", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/region", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include generations" do
    get "/api/v3/region", params: { q: "kanto", include: "generations" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "kanto", result["name"]
    assert_equal 1, result["generations"].size
    assert_equal "generation-i", result.dig("generations", 0, "name")
    assert_match(%r{/api/v3/generation/\d+/$}, result.dig("generations", 0, "url"))
  end

  test "show returns region payload with standardized keys" do
    region = PokeRegion.find_by!(name: "kanto")

    get "/api/v3/region/#{region.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url], payload.keys.sort
    assert_equal region.id, payload["id"]
    assert_equal "kanto", payload["name"]
    assert_match(%r{/api/v3/region/#{region.id}/$}, payload["url"])
  end

  test "show supports include generations" do
    region = PokeRegion.find_by!(name: "kanto")

    get "/api/v3/region/#{region.id}", params: { include: "generations" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["generations"].size
    assert_equal "generation-i", payload.dig("generations", 0, "name")
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/region/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/region", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/region", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/region", params: { sort: "generation_id" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal [ "generation_id" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/region", params: { filter: { generation_id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal [ "generation_id" ], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    region = PokeRegion.find_by!(name: "kanto")

    get "/api/v3/region/"
    assert_response :success

    get "/api/v3/region/#{region.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/region", params: { limit: 3, offset: 0, q: "o" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/region", params: { limit: 3, offset: 0, q: "o" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    region = PokeRegion.find_by!(name: "kanto")

    get "/api/v3/region/#{region.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/region/#{region.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/region", params: { limit: 3, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/region", params: { limit: 3, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "list etag varies by include parameter" do
    get "/api/v3/region", params: { q: "kanto" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/region", params: { q: "kanto", include: "generations" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    region = PokeRegion.find_by!(name: "kanto")

    get "/api/v3/region/#{region.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/region/#{region.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
