require "test_helper"

class Api::V3::BerryControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeBerry.delete_all

    [
      { name: "cheri", item_id: 126, berry_firmness_id: 2, natural_gift_power: 60, natural_gift_type_id: 10, size: 20, max_harvest: 5, growth_time: 3, soil_dryness: 15, smoothness: 25 },
      { name: "chesto", item_id: 127, berry_firmness_id: 5, natural_gift_power: 60, natural_gift_type_id: 11, size: 80, max_harvest: 5, growth_time: 3, soil_dryness: 15, smoothness: 25 },
      { name: "pecha", item_id: 128, berry_firmness_id: 1, natural_gift_power: 60, natural_gift_type_id: 13, size: 40, max_harvest: 5, growth_time: 3, soil_dryness: 15, smoothness: 25 },
      { name: "rawst", item_id: 129, berry_firmness_id: 3, natural_gift_power: 60, natural_gift_type_id: 12, size: 32, max_harvest: 5, growth_time: 3, soil_dryness: 15, smoothness: 25 },
      { name: "aspear", item_id: 130, berry_firmness_id: 5, natural_gift_power: 60, natural_gift_type_id: 15, size: 50, max_harvest: 5, growth_time: 3, soil_dryness: 15, smoothness: 25 }
    ].each do |attrs|
      PokeBerry.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/berry", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/berry/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/berry", params: { q: "che" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 2, payload["count"]
  end

  test "list supports filter by name" do
    get "/api/v3/berry", params: { filter: { name: "cheri" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "cheri", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/berry", params: { q: "che", filter: { name: "chesto" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "chesto", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/berry", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "rawst", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/berry", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "show returns berry payload with standardized keys" do
    berry = PokeBerry.find_by!(name: "cheri")

    get "/api/v3/berry/#{berry.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[firmness_id growth_time id item_id max_harvest name natural_gift_power natural_gift_type_id size smoothness soil_dryness url], payload.keys.sort
    assert_equal berry.id, payload["id"]
    assert_equal "cheri", payload["name"]
    assert_equal 126, payload["item_id"]
    assert_equal 2, payload["firmness_id"]
    assert_equal 60, payload["natural_gift_power"]
    assert_equal 10, payload["natural_gift_type_id"]
    assert_match(%r{/api/v3/berry/#{berry.id}/$}, payload["url"])
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/berry/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/berry", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/berry", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/berry", params: { sort: "item_id" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal [ "item_id" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/berry", params: { filter: { item_id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal [ "item_id" ], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    berry = PokeBerry.find_by!(name: "cheri")

    get "/api/v3/berry/"
    assert_response :success

    get "/api/v3/berry/#{berry.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/berry", params: { limit: 2, offset: 0, q: "che" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry", params: { limit: 2, offset: 0, q: "che" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    berry = PokeBerry.find_by!(name: "cheri")

    get "/api/v3/berry/#{berry.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry/#{berry.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/berry", params: { limit: 2, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry", params: { limit: 2, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    berry = PokeBerry.find_by!(name: "cheri")

    get "/api/v3/berry/#{berry.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/berry/#{berry.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
