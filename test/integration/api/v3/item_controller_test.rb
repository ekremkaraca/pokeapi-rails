require "test_helper"

class Api::V3::ItemControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeItem.delete_all
    PokeItemCategory.delete_all

    medicine = PokeItemCategory.create!(name: "medicine", pocket_id: 1)
    pokeballs = PokeItemCategory.create!(name: "pokeballs", pocket_id: 2)

    [
      { name: "potion", cost: 300, category_id: medicine.id, fling_power: nil, fling_effect_id: nil },
      { name: "super-potion", cost: 700, category_id: medicine.id, fling_power: nil, fling_effect_id: nil },
      { name: "hyper-potion", cost: 1200, category_id: medicine.id, fling_power: nil, fling_effect_id: nil },
      { name: "poke-ball", cost: 200, category_id: pokeballs.id, fling_power: nil, fling_effect_id: nil },
      { name: "great-ball", cost: 600, category_id: pokeballs.id, fling_power: nil, fling_effect_id: nil }
    ].each do |attrs|
      PokeItem.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/item", params: { limit: 3, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 3, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[cost id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/item/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/item", params: { q: "potion" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 3, payload["count"]
    assert_includes names, "potion"
    assert_includes names, "super-potion"
    assert_includes names, "hyper-potion"
  end

  test "list supports filter by name" do
    get "/api/v3/item", params: { filter: { name: "poke-ball" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "poke-ball", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/item", params: { q: "potion", filter: { name: "super-potion" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "super-potion", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/item", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "super-potion", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/item", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include category" do
    get "/api/v3/item", params: { q: "potion", include: "category" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "potion", result["name"]
    assert_equal "medicine", result.dig("category", "name")
    assert_match(%r{/api/v3/item-category/\d+/$}, result.dig("category", "url"))
  end

  test "show returns item payload with standardized keys" do
    item = PokeItem.find_by!(name: "potion")

    get "/api/v3/item/#{item.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[category_id cost fling_effect_id fling_power id name url], payload.keys.sort
    assert_equal item.id, payload["id"]
    assert_equal "potion", payload["name"]
    assert_equal 300, payload["cost"]
    assert_match(%r{/api/v3/item/#{item.id}/$}, payload["url"])
  end

  test "show supports include category" do
    item = PokeItem.find_by!(name: "potion")

    get "/api/v3/item/#{item.id}", params: { include: "category" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal "medicine", payload.dig("category", "name")
    assert_match(%r{/api/v3/item-category/\d+/$}, payload.dig("category", "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/item/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/item", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/item", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal [ "unknown" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/item", params: { sort: "cost" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal [ "cost" ], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/item", params: { filter: { category_id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal [ "category_id" ], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    item = PokeItem.find_by!(name: "potion")

    get "/api/v3/item/"
    assert_response :success

    get "/api/v3/item/#{item.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/item", params: { limit: 3, offset: 0, q: "potion" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item", params: { limit: 3, offset: 0, q: "potion" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    item = PokeItem.find_by!(name: "potion")

    get "/api/v3/item/#{item.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item/#{item.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by sort parameter" do
    get "/api/v3/item", params: { limit: 3, sort: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item", params: { limit: 3, sort: "-name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "list etag varies by include parameter" do
    get "/api/v3/item", params: { q: "potion" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item", params: { q: "potion", include: "category" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    item = PokeItem.find_by!(name: "potion")

    get "/api/v3/item/#{item.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item/#{item.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
