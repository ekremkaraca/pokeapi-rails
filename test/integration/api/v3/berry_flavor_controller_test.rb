require "test_helper"

class Api::V3::BerryFlavorControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeBerryFlavor.delete_all
    PokeContestType.delete_all

    cool = PokeContestType.create!(name: "cool")
    beauty = PokeContestType.create!(name: "beauty")
    smart = PokeContestType.create!(name: "smart")

    [
      { name: "spicy", contest_type_id: cool.id },
      { name: "dry", contest_type_id: beauty.id },
      { name: "bitter", contest_type_id: smart.id }
    ].each do |attrs|
      PokeBerryFlavor.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/berry-flavor", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/berry-flavor/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/berry-flavor", params: { q: "sp" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "spicy", payload.dig("results", 0, "name")
  end

  test "list supports filter by name" do
    get "/api/v3/berry-flavor", params: { filter: { name: "dry" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "dry", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/berry-flavor", params: { q: "sp", filter: { name: "spicy" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "spicy", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/berry-flavor", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "spicy", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/berry-flavor", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include contest_type" do
    get "/api/v3/berry-flavor", params: { filter: { name: "spicy" }, include: "contest_type" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "spicy", result["name"]
    assert_equal "cool", result.dig("contest_type", "name")
    assert_match(%r{/api/v2/contest-type/\d+/$}, result.dig("contest_type", "url"))
  end

  test "show returns berry flavor payload with standardized keys" do
    flavor = PokeBerryFlavor.find_by!(name: "spicy")

    get "/api/v3/berry-flavor/#{flavor.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[contest_type_id id name url], payload.keys.sort
    assert_equal flavor.id, payload["id"]
    assert_equal "spicy", payload["name"]
    assert_match(%r{/api/v3/berry-flavor/#{flavor.id}/$}, payload["url"])
  end

  test "show supports include contest_type" do
    flavor = PokeBerryFlavor.find_by!(name: "dry")

    get "/api/v3/berry-flavor/#{flavor.id}", params: { include: "contest_type" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "beauty", payload.dig("contest_type", "name")
    assert_match(%r{/api/v2/contest-type/\d+/$}, payload.dig("contest_type", "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/berry-flavor/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/berry-flavor", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/berry-flavor", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/berry-flavor", params: { sort: "created_at" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["created_at"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/berry-flavor", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["id"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    flavor = PokeBerryFlavor.find_by!(name: "spicy")

    get "/api/v3/berry-flavor/"
    assert_response :success

    get "/api/v3/berry-flavor/#{flavor.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/berry-flavor", params: { limit: 2, offset: 0, q: "sp" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry-flavor", params: { limit: 2, offset: 0, q: "sp" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    flavor = PokeBerryFlavor.find_by!(name: "spicy")

    get "/api/v3/berry-flavor/#{flavor.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry-flavor/#{flavor.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by include parameter" do
    get "/api/v3/berry-flavor", params: { q: "sp" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry-flavor", params: { q: "sp", include: "contest_type" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    flavor = PokeBerryFlavor.find_by!(name: "spicy")

    get "/api/v3/berry-flavor/#{flavor.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry-flavor/#{flavor.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
