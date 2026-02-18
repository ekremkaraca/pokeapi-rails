require "test_helper"

class Api::V2::ItemFlingEffectControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeItemFlingEffect.delete_all

    %w[burn poison flinch herb-effect berry-effect].each do |name|
      PokeItemFlingEffect.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/item-fling-effect", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/item-fling-effect/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/item-fling-effect/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/item-fling-effect", params: { q: "herb" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal ["herb-effect"], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    effect = PokeItemFlingEffect.find_by!(name: "burn")

    get "/api/v2/item-fling-effect/#{effect.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal effect.id, payload["id"]
    assert_equal "burn", payload["name"]

    get "/api/v2/item-fling-effect/BURN"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    effect = PokeItemFlingEffect.find_by!(name: "burn")

    get "/api/v2/item-fling-effect/"
    assert_response :success

    get "/api/v2/item-fling-effect/#{effect.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/item-fling-effect/%2A%2A"

    assert_response :not_found
  end
end
