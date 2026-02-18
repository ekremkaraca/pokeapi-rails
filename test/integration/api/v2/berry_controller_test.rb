require "test_helper"

class Api::V2::BerryControllerTest < ActionDispatch::IntegrationTest
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

  test "list returns paginated summary data" do
    get "/api/v2/berry", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/berry/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/berry/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/berry", params: { q: "che" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 2, payload["count"]
  end

  test "show supports retrieval by id and name" do
    berry = PokeBerry.find_by!(name: "cheri")

    get "/api/v2/berry/#{berry.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal berry.id, payload["id"]
    assert_equal "cheri", payload["name"]
    assert_equal 126, payload["item_id"]
    assert_equal 2, payload["firmness_id"]
    assert_equal 60, payload["natural_gift_power"]
    assert_equal 10, payload["natural_gift_type_id"]

    get "/api/v2/berry/CHERI"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    berry = PokeBerry.find_by!(name: "cheri")

    get "/api/v2/berry/"
    assert_response :success

    get "/api/v2/berry/#{berry.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/berry/%2A%2A"

    assert_response :not_found
  end
end
