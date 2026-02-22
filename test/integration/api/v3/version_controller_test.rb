require "test_helper"

class Api::V3::VersionControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeVersion.delete_all
    PokeVersionGroup.delete_all
    PokeGeneration.delete_all

    generation_i = PokeGeneration.create!(name: "generation-i", main_region_id: nil)
    generation_ii = PokeGeneration.create!(name: "generation-ii", main_region_id: nil)
    vg_i = PokeVersionGroup.create!(name: "red-blue", generation_id: generation_i.id, sort_order: 1)
    vg_ii = PokeVersionGroup.create!(name: "gold-silver", generation_id: generation_ii.id, sort_order: 2)

    [
      { name: "red", version_group_id: vg_i.id },
      { name: "blue", version_group_id: vg_i.id },
      { name: "yellow", version_group_id: vg_i.id },
      { name: "gold", version_group_id: vg_ii.id },
      { name: "silver", version_group_id: vg_ii.id }
    ].each do |attrs|
      PokeVersion.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/version", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/version/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/version", params: { q: "sil" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "silver", payload["results"].first["name"]
  end

  test "list supports filter by name" do
    get "/api/v3/version", params: { filter: { name: "blue" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "blue", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/version", params: { q: "ye", filter: { name: "yellow" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "yellow", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/version", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "yellow", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/version", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include version_group" do
    get "/api/v3/version", params: { q: "red", include: "version_group" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "red", result["name"]
    assert_equal "red-blue", result.dig("version_group", "name")
    assert_match(%r{/api/v3/version-group/\d+/$}, result.dig("version_group", "url"))
  end

  test "show returns version payload with standardized keys" do
    version = PokeVersion.find_by!(name: "red")

    get "/api/v3/version/#{version.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url version_group_id], payload.keys.sort
    assert_equal version.id, payload["id"]
    assert_equal "red", payload["name"]
    assert_match(%r{/api/v3/version/#{version.id}/$}, payload["url"])
  end

  test "show supports include version_group" do
    version = PokeVersion.find_by!(name: "red")

    get "/api/v3/version/#{version.id}", params: { include: "version_group" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "red-blue", payload.dig("version_group", "name")
    assert_match(%r{/api/v3/version-group/\d+/$}, payload.dig("version_group", "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/version/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_not_found_error_envelope(payload)
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/version", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "fields", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/version", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "include", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/version", params: { sort: "version_group_id" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "sort", invalid_values: [ "version_group_id" ])
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/version", params: { filter: { version_group_id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "filter", invalid_values: [ "version_group_id" ])
  end

  test "list and show accept trailing slash" do
    version = PokeVersion.find_by!(name: "red")

    get "/api/v3/version/"
    assert_response :success

    get "/api/v3/version/#{version.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/version", params: { limit: 3, offset: 0, q: "l" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/version", params: { limit: 3, offset: 0, q: "l" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    version = PokeVersion.find_by!(name: "red")

    get "/api/v3/version/#{version.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/version/#{version.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/version", params: { limit: 3, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/version", params: { limit: 3, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "list etag varies by include parameter" do
    get "/api/v3/version", params: { q: "red" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/version", params: { q: "red", include: "version_group" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    version = PokeVersion.find_by!(name: "red")

    get "/api/v3/version/#{version.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/version/#{version.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
