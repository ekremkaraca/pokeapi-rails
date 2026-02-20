require "test_helper"

class Api::V3::ItemPocketControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeItemCategory.delete_all
    PokeItemPocket.delete_all

    items = PokeItemPocket.create!(name: "items")
    medicine = PokeItemPocket.create!(name: "medicine")
    balls = PokeItemPocket.create!(name: "balls")

    [
      { name: "stat-boosts", pocket_id: items.id },
      { name: "effort-drop", pocket_id: medicine.id },
      { name: "medicine", pocket_id: medicine.id },
      { name: "standard-balls", pocket_id: balls.id }
    ].each do |attrs|
      PokeItemCategory.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/item-pocket", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/item-pocket/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/item-pocket", params: { q: "med" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "medicine", payload.dig("results", 0, "name")
  end

  test "list supports filter by name" do
    get "/api/v3/item-pocket", params: { filter: { name: "balls" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "balls", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/item-pocket", params: { q: "med", filter: { name: "medicine" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "medicine", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/item-pocket", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "medicine", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/item-pocket", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include item_categories" do
    get "/api/v3/item-pocket", params: { filter: { name: "medicine" }, include: "item_categories" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "medicine", result["name"]
    assert_equal %w[effort-drop medicine], result.fetch("item_categories").map { |category| category.fetch("name") }.sort
    assert_match(%r{/api/v3/item-category/\d+/$}, result.dig("item_categories", 0, "url"))
  end

  test "show returns item pocket payload with standardized keys" do
    pocket = PokeItemPocket.find_by!(name: "items")

    get "/api/v3/item-pocket/#{pocket.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url], payload.keys.sort
    assert_equal pocket.id, payload["id"]
    assert_equal "items", payload["name"]
    assert_match(%r{/api/v3/item-pocket/#{pocket.id}/$}, payload["url"])
  end

  test "show supports include item_categories" do
    pocket = PokeItemPocket.find_by!(name: "balls")

    get "/api/v3/item-pocket/#{pocket.id}", params: { include: "item_categories" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal ["standard-balls"], payload.fetch("item_categories").map { |category| category.fetch("name") }
    assert_match(%r{/api/v3/item-category/\d+/$}, payload.dig("item_categories", 0, "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/item-pocket/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/item-pocket", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/item-pocket", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/item-pocket", params: { sort: "created_at" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["created_at"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/item-pocket", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["id"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    pocket = PokeItemPocket.find_by!(name: "items")

    get "/api/v3/item-pocket/"
    assert_response :success

    get "/api/v3/item-pocket/#{pocket.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/item-pocket", params: { limit: 2, offset: 0, q: "med" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-pocket", params: { limit: 2, offset: 0, q: "med" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    pocket = PokeItemPocket.find_by!(name: "items")

    get "/api/v3/item-pocket/#{pocket.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-pocket/#{pocket.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by include parameter" do
    get "/api/v3/item-pocket", params: { q: "med" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-pocket", params: { q: "med", include: "item_categories" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    pocket = PokeItemPocket.find_by!(name: "items")

    get "/api/v3/item-pocket/#{pocket.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-pocket/#{pocket.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
