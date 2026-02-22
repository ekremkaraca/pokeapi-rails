require "test_helper"

class Api::V3::ItemFlingEffectControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeItem.delete_all
    PokeItemFlingEffect.delete_all

    burn = PokeItemFlingEffect.create!(name: "burn")
    bad_poison = PokeItemFlingEffect.create!(name: "badly-poison")
    flinch = PokeItemFlingEffect.create!(name: "flinch")

    [
      { name: "flame-orb", fling_effect_id: burn.id, category_id: 1, cost: 3000 },
      { name: "toxic-orb", fling_effect_id: bad_poison.id, category_id: 1, cost: 3000 },
      { name: "king's-rock", fling_effect_id: flinch.id, category_id: 1, cost: 5000 },
      { name: "razor-fang", fling_effect_id: flinch.id, category_id: 1, cost: 5000 }
    ].each do |attrs|
      PokeItem.create!(attrs)
    end
  end

  test "list returns paginated summary data with id name and url" do
    get "/api/v3/item-fling-effect", params: { limit: 2, offset: 0 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_nil payload["previous"]
    assert_equal %w[id name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v3/item-fling-effect/\d+/$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v3/item-fling-effect", params: { q: "poison" }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "badly-poison", payload.dig("results", 0, "name")
  end

  test "list supports filter by name" do
    get "/api/v3/item-fling-effect", params: { filter: { name: "burn" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "burn", payload.dig("results", 0, "name")
  end

  test "list combines q and filter with and semantics" do
    get "/api/v3/item-fling-effect", params: { q: "flinch", filter: { name: "flinch" } }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 1, payload["count"]
    assert_equal "flinch", payload.dig("results", 0, "name")
  end

  test "list supports sort parameter" do
    get "/api/v3/item-fling-effect", params: { sort: "-name" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "flinch", payload.fetch("results").first.fetch("name")
  end

  test "list supports fields filter" do
    get "/api/v3/item-fling-effect", params: { limit: 1, fields: "name,url" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[name url], payload["results"].first.keys.sort
  end

  test "list supports include items" do
    get "/api/v3/item-fling-effect", params: { filter: { name: "flinch" }, include: "items" }
    assert_response :success
    payload = JSON.parse(response.body)

    result = payload.fetch("results").first
    assert_equal "flinch", result["name"]
    assert_equal [ "king's-rock", "razor-fang" ], result.fetch("items").map { |item| item.fetch("name") }.sort
    assert_match(%r{/api/v3/item/\d+/$}, result.dig("items", 0, "url"))
  end

  test "show returns item fling effect payload with standardized keys" do
    effect = PokeItemFlingEffect.find_by!(name: "burn")

    get "/api/v3/item-fling-effect/#{effect.id}"
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal %w[id name url], payload.keys.sort
    assert_equal effect.id, payload["id"]
    assert_equal "burn", payload["name"]
    assert_match(%r{/api/v3/item-fling-effect/#{effect.id}/$}, payload["url"])
  end

  test "show supports include items" do
    effect = PokeItemFlingEffect.find_by!(name: "badly-poison")

    get "/api/v3/item-fling-effect/#{effect.id}", params: { include: "items" }
    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal [ "toxic-orb" ], payload.fetch("items").map { |item| item.fetch("name") }
    assert_match(%r{/api/v3/item/\d+/$}, payload.dig("items", 0, "url"))
  end

  test "show returns standardized not found envelope for invalid token" do
    get "/api/v3/item-fling-effect/not-a-number"

    assert_response :not_found
    payload = JSON.parse(response.body)

    assert_not_found_error_envelope(payload)
  end

  test "returns bad request for invalid fields parameter" do
    get "/api/v3/item-fling-effect", params: { fields: "name,unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "fields", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid include parameter" do
    get "/api/v3/item-fling-effect", params: { include: "unknown" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "include", invalid_values: [ "unknown" ])
  end

  test "returns bad request for invalid sort parameter" do
    get "/api/v3/item-fling-effect", params: { sort: "created_at" }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "sort", invalid_values: [ "created_at" ])
  end

  test "returns bad request for invalid filter parameter" do
    get "/api/v3/item-fling-effect", params: { filter: { id: "1" } }

    assert_response :bad_request
    payload = JSON.parse(response.body)

    assert_invalid_query_error(payload, param: "filter", invalid_values: [ "id" ])
  end

  test "list and show accept trailing slash" do
    effect = PokeItemFlingEffect.find_by!(name: "burn")

    get "/api/v3/item-fling-effect/"
    assert_response :success

    get "/api/v3/item-fling-effect/#{effect.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v3/item-fling-effect", params: { limit: 2, offset: 0, q: "flinch" }
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-fling-effect", params: { limit: 2, offset: 0, q: "flinch" }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    effect = PokeItemFlingEffect.find_by!(name: "burn")

    get "/api/v3/item-fling-effect/#{effect.id}"
    assert_response :success

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-fling-effect/#{effect.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "list etag varies by include parameter" do
    get "/api/v3/item-fling-effect", params: { q: "flinch" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-fling-effect", params: { q: "flinch", include: "items" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end

  test "show etag varies by fields parameter" do
    effect = PokeItemFlingEffect.find_by!(name: "burn")

    get "/api/v3/item-fling-effect/#{effect.id}", params: { fields: "name" }
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v3/item-fling-effect/#{effect.id}", params: { fields: "id,name" }, headers: { "If-None-Match" => etag }
    assert_response :success
  end
end
