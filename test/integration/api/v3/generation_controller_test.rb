require "test_helper"

class Api::V3::GenerationControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeGeneration.delete_all
    PokeRegion.delete_all

    kanto = PokeRegion.create!(name: "kanto")
    johto = PokeRegion.create!(name: "johto")

    [
      { name: "generation-i", main_region_id: kanto.id },
      { name: "generation-ii", main_region_id: johto.id },
      { name: "generation-iii", main_region_id: nil },
      { name: "generation-iv", main_region_id: nil },
      { name: "generation-v", main_region_id: nil }
    ].each do |attrs|
      PokeGeneration.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/generation", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/generation/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/generation", params: { q: "ii" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 2, payload["count"]
    assert_includes names, "generation-ii"
    assert_includes names, "generation-iii"
  end

  test "list supports filter by name" do
    get "/api/v3/generation", params: { filter: { name: "generation-i" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "generation-i", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/generation", params: { q: "ii", filter: { name: "generation-ii" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "generation-ii", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/generation", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "generation-v", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/generation", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include main_region" do
    get "/api/v3/generation", params: { q: "generation-i", include: "main_region" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "generation-i", result["name"]
    assert_equal "kanto", result.dig("main_region", "name")
    assert_match(%r{/api/v2/region/\d+/$}, result.dig("main_region", "url"))
  end

  test "show returns generation payload with standardized keys" do
    generation = PokeGeneration.find_by!(name: "generation-i")

    get "/api/v3/generation/#{generation.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id main_region_id name url], payload.keys.sort
    assert_equal generation.id, payload["id"]
    assert_equal "generation-i", payload["name"]
    assert_match(%r{/api/v3/generation/#{generation.id}/$}, payload["url"])
  end

  test "show supports include main_region" do
    generation = PokeGeneration.find_by!(name: "generation-i")

    get "/api/v3/generation/#{generation.id}", params: { include: "main_region" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "kanto", payload.dig("main_region", "name")
    assert_match(%r{/api/v2/region/\d+/$}, payload.dig("main_region", "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/generation/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/generation", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/generation", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/generation", params: { sort: "main_region_id" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["main_region_id"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/generation", params: { filter: { main_region_id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["main_region_id"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    generation = PokeGeneration.find_by!(name: "generation-i")

    get "/api/v3/generation/"
    assert_response :success

    get "/api/v3/generation/#{generation.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/generation", params: { limit: 3, offset: 0, q: "generation" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/generation", params: { limit: 3, offset: 0, q: "generation" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    generation = PokeGeneration.find_by!(name: "generation-i")

    get "/api/v3/generation/#{generation.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/generation/#{generation.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/generation", params: { limit: 3, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/generation", params: { limit: 3, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "list etag varies by include parameter" do
    get "/api/v3/generation", params: { q: "generation-i" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/generation", params: { q: "generation-i", include: "main_region" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    generation = PokeGeneration.find_by!(name: "generation-i")

    get "/api/v3/generation/#{generation.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/generation/#{generation.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
