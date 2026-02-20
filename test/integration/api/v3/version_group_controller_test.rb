require "test_helper"

class Api::V3::VersionGroupControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeVersionGroup.delete_all
    PokeGeneration.delete_all

    generation_i = PokeGeneration.create!(name: "generation-i", main_region_id: nil)
    generation_ii = PokeGeneration.create!(name: "generation-ii", main_region_id: nil)

    [
      { name: "red-blue", generation_id: generation_i.id, sort_order: 1 },
      { name: "yellow", generation_id: generation_i.id, sort_order: 2 },
      { name: "gold-silver", generation_id: generation_ii.id, sort_order: 3 },
      { name: "crystal", generation_id: generation_ii.id, sort_order: 4 },
      { name: "firered-leafgreen", generation_id: generation_i.id, sort_order: 5 }
    ].each do |attrs|
      PokeVersionGroup.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/version-group", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/version-group/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/version-group", params: { q: "silver" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "gold-silver", payload["results"].first["name"]
  end

  test "list supports filter by name" do
    get "/api/v3/version-group", params: { filter: { name: "yellow" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "yellow", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/version-group", params: { q: "gold", filter: { name: "gold-silver" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "gold-silver", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/version-group", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "yellow", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/version-group", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include generation" do
    get "/api/v3/version-group", params: { q: "red-blue", include: "generation" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "red-blue", result["name"]
    assert_equal "generation-i", result.dig("generation", "name")
    assert_match(%r{/api/v3/generation/\d+/$}, result.dig("generation", "url"))
  end

  test "show returns version-group payload with standardized keys" do
    version_group = PokeVersionGroup.find_by!(name: "red-blue")

    get "/api/v3/version-group/#{version_group.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[generation_id id name sort_order url], payload.keys.sort
    assert_equal version_group.id, payload["id"]
    assert_equal "red-blue", payload["name"]
    assert_match(%r{/api/v3/version-group/#{version_group.id}/$}, payload["url"])
  end

  test "show supports include generation" do
    version_group = PokeVersionGroup.find_by!(name: "red-blue")

    get "/api/v3/version-group/#{version_group.id}", params: { include: "generation" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "generation-i", payload.dig("generation", "name")
    assert_match(%r{/api/v3/generation/\d+/$}, payload.dig("generation", "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/version-group/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/version-group", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/version-group", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/version-group", params: { sort: "sort_order" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal [ "sort_order" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/version-group", params: { filter: { generation_id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal [ "generation_id" ], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    version_group = PokeVersionGroup.find_by!(name: "red-blue")

    get "/api/v3/version-group/"
    assert_response :success

    get "/api/v3/version-group/#{version_group.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/version-group", params: { limit: 3, offset: 0, q: "red" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/version-group", params: { limit: 3, offset: 0, q: "red" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    version_group = PokeVersionGroup.find_by!(name: "red-blue")

    get "/api/v3/version-group/#{version_group.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/version-group/#{version_group.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/version-group", params: { limit: 3, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/version-group", params: { limit: 3, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "list etag varies by include parameter" do
    get "/api/v3/version-group", params: { q: "red-blue" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/version-group", params: { q: "red-blue", include: "generation" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    version_group = PokeVersionGroup.find_by!(name: "red-blue")

    get "/api/v3/version-group/#{version_group.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/version-group/#{version_group.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
