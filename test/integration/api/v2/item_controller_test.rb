require "test_helper"

class Api::V2::ItemControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeItem.delete_all

    [
      { name: "master-ball", category_id: 34, cost: 0, fling_power: nil, fling_effect_id: nil },
      { name: "ultra-ball", category_id: 34, cost: 800, fling_power: nil, fling_effect_id: nil },
      { name: "great-ball", category_id: 34, cost: 600, fling_power: nil, fling_effect_id: nil },
      { name: "potion", category_id: 27, cost: 200, fling_power: 30, fling_effect_id: 7 },
      { name: "antidote", category_id: 30, cost: 200, fling_power: 30, fling_effect_id: 6 }
    ].each do |attrs|
      PokeItem.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/item", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/item/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/item/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/item", params: { q: "ball" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 3, payload["count"]
    assert_equal ["master-ball", "ultra-ball", "great-ball"].sort, payload["results"].map { |record| record["name"] }.sort
  end

  test "show supports retrieval by id and name" do
    item = PokeItem.find_by!(name: "potion")

    get "/api/v2/item/#{item.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[attributes baby_trigger_for category cost effect_entries flavor_text_entries fling_effect fling_power game_indices held_by_pokemon id machines name names sprites], payload.keys.sort
    assert_equal item.id, payload["id"]
    assert_equal "potion", payload["name"]
    assert_nil payload["category"]
    assert_equal 200, payload["cost"]
    assert_equal 30, payload["fling_power"]
    assert_nil payload["fling_effect"]
    assert_equal [], payload["attributes"]
    assert_equal [], payload["effect_entries"]
    assert_equal [], payload["flavor_text_entries"]
    assert_equal [], payload["game_indices"]
    assert_equal [], payload["held_by_pokemon"]
    assert_equal [], payload["machines"]
    assert_equal [], payload["names"]
    assert_nil payload["baby_trigger_for"]
    assert_match(%r{/sprites/items/potion\.png\z}, payload["sprites"]["default"])

    get "/api/v2/item/POTION"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    item = PokeItem.find_by!(name: "potion")

    get "/api/v2/item/"
    assert_response :success

    get "/api/v2/item/#{item.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/item/%2A%2A"

    assert_response :not_found
  end
end
