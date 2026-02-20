require "test_helper"

class Api::V3::ItemAttributeControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeItemFlagMap.delete_all
    PokeItem.delete_all
    PokeItemAttribute.delete_all

    countable = PokeItemAttribute.create!(name: "countable")
    holdable = PokeItemAttribute.create!(name: "holdable")
    usable_overworld = PokeItemAttribute.create!(name: "usable-overworld")

    potion = PokeItem.create!(name: "potion", category_id: 1, cost: 300)
    antidote = PokeItem.create!(name: "antidote", category_id: 1, cost: 100)
    poke_ball = PokeItem.create!(name: "poke-ball", category_id: 2, cost: 200)

    [
      { item_id: potion.id, item_flag_id: countable.id },
      { item_id: potion.id, item_flag_id: usable_overworld.id },
      { item_id: antidote.id, item_flag_id: holdable.id },
      { item_id: poke_ball.id, item_flag_id: countable.id }
    ].each do |attrs|
      PokeItemFlagMap.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/item-attribute", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/item-attribute/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/item-attribute", params: { q: "count" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "countable", payload.dig("results", 0, "name")
  end

  test "list supports filter by name" do
    get "/api/v3/item-attribute", params: { filter: { name: "holdable" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "holdable", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/item-attribute", params: { q: "hold", filter: { name: "holdable" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "holdable", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/item-attribute", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "usable-overworld", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/item-attribute", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include items" do
    get "/api/v3/item-attribute", params: { filter: { name: "countable" }, include: "items" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "countable", result["name"]
    assert_equal %w[poke-ball potion], result.fetch("items").map { |item| item.fetch("name") }.sort
    assert_match(%r{/api/v3/item/\d+/$}, result.dig("items", 0, "url"))
  end

  test "show returns item attribute payload with standardized keys" do
    attribute = PokeItemAttribute.find_by!(name: "holdable")

    get "/api/v3/item-attribute/#{attribute.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url], payload.keys.sort
    assert_equal attribute.id, payload["id"]
    assert_equal "holdable", payload["name"]
    assert_match(%r{/api/v3/item-attribute/#{attribute.id}/$}, payload["url"])
  end

  test "show supports include items" do
    attribute = PokeItemAttribute.find_by!(name: "holdable")

    get "/api/v3/item-attribute/#{attribute.id}", params: { include: "items" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal ["antidote"], payload.fetch("items").map { |item| item.fetch("name") }
    assert_match(%r{/api/v3/item/\d+/$}, payload.dig("items", 0, "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/item-attribute/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_equal "not_found", payload.dig("error", "code")
    assert_equal "Resource not found", payload.dig("error", "message")
    assert_kind_of Hash, payload.dig("error", "details")
    assert_kind_of String, payload.dig("error", "request_id")
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/item-attribute", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "fields", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/item-attribute", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "include", payload.dig("error", "details", "param")
    assert_equal ["unknown"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/item-attribute", params: { sort: "created_at" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "sort", payload.dig("error", "details", "param")
    assert_equal ["created_at"], payload.dig("error", "details", "invalid_values")
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/item-attribute", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_equal "invalid_query", payload.dig("error", "code")
    assert_equal "filter", payload.dig("error", "details", "param")
    assert_equal ["id"], payload.dig("error", "details", "invalid_values")
  end

  test "list and show accept trailing slash" do
    attribute = PokeItemAttribute.find_by!(name: "holdable")

    get "/api/v3/item-attribute/"
    assert_response :success

    get "/api/v3/item-attribute/#{attribute.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/item-attribute", params: { limit: 2, offset: 0, q: "hold" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-attribute", params: { limit: 2, offset: 0, q: "hold" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    attribute = PokeItemAttribute.find_by!(name: "holdable")

    get "/api/v3/item-attribute/#{attribute.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-attribute/#{attribute.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_match(/\A\d+\z/, response.headers["X-Query-Count"])
    assert_match(/\A\d+(\.\d+)?\z/, response.headers["X-Response-Time-Ms"])
    assert_equal "", response.body
  end

  test "list etag varies by include parameter" do
    get "/api/v3/item-attribute", params: { q: "count" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-attribute", params: { q: "count", include: "items" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    attribute = PokeItemAttribute.find_by!(name: "holdable")

    get "/api/v3/item-attribute/#{attribute.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-attribute/#{attribute.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
