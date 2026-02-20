require "test_helper"

class Api::V3::MoveCategoryControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMoveMetaCategory.delete_all

    %w[damage ailment net-good-stats heal damage+ailment field-effect].each do |name|
      PokeMoveMetaCategory.create!(name: name)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/move-category", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 6, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/move-category/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/move-category", params: { q: "effect" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal ["field-effect"], names
  end

  test "list supports filter by name" do
    get "/api/v3/move-category", params: { filter: { name: "damage" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "damage", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/move-category", params: { q: "field", filter: { name: "field-effect" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "field-effect", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/move-category", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "net-good-stats", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/move-category", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns move-category payload with standardized keys" do
    category = PokeMoveMetaCategory.find_by!(name: "damage")

    get "/api/v3/move-category/#{category.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url], payload.keys.sort
    assert_equal category.id, payload["id"]
    assert_equal "damage", payload["name"]
    assert_match(%r{/api/v3/move-category/#{category.id}/$}, payload["url"])
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/move-category/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/move-category", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/move-category", params: { include: "anything" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["anything"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/move-category", params: { sort: "url" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["url"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/move-category", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["id"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    category = PokeMoveMetaCategory.find_by!(name: "damage")

    get "/api/v3/move-category/"
    assert_response :success

    get "/api/v3/move-category/#{category.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/move-category", params: { limit: 2, offset: 0, q: "field" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-category", params: { limit: 2, offset: 0, q: "field" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    category = PokeMoveMetaCategory.find_by!(name: "damage")

    get "/api/v3/move-category/#{category.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-category/#{category.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/move-category", params: { q: "damage" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-category", params: { q: "damage", sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    category = PokeMoveMetaCategory.find_by!(name: "damage")

    get "/api/v3/move-category/#{category.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/move-category/#{category.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
