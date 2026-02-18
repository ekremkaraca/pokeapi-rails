require "test_helper"

class Api::V2::LocationControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeLocation.delete_all

    [
      { name: "canalave-city", region_id: 4 },
      { name: "eterna-city", region_id: 4 },
      { name: "pastoria-city", region_id: 4 },
      { name: "sunyshore-city", region_id: 4 },
      { name: "lavender-town", region_id: 2 }
    ].each do |attrs|
      PokeLocation.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/location", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/location/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/location/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/location", params: { q: "city" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 4, payload["count"]
  end

  test "show supports retrieval by id and name" do
    location = PokeLocation.find_by!(name: "canalave-city")

    get "/api/v2/location/#{location.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[areas game_indices id name names region], payload.keys.sort
    assert_equal location.id, payload["id"]
    assert_equal "canalave-city", payload["name"]
    assert_equal [], payload["areas"]
    assert_equal [], payload["game_indices"]
    assert_equal [], payload["names"]
    assert_nil payload["region"]

    get "/api/v2/location/CANALAVE-CITY"
    assert_response :success
  end

  test "list and show accept trailing slash" do
    location = PokeLocation.find_by!(name: "canalave-city")

    get "/api/v2/location/"
    assert_response :success

    get "/api/v2/location/#{location.id}/"
    assert_response :success
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/location/%2A%2A"

    assert_response :not_found
  end
end
