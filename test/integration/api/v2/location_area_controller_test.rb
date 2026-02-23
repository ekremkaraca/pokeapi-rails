require "test_helper"

class Api::V2::LocationAreaControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeLocationArea.delete_all

    [
      { name: "canalave-city-area", location_id: 1, game_index: 1 },
      { name: "eterna-city-area", location_id: 2, game_index: 2 },
      { name: "oreburgh-mine-1f", location_id: 6, game_index: 6 },
      { name: "oreburgh-mine-b1f", location_id: 6, game_index: 7 },
      { name: "great-marsh-area-1", location_id: 11, game_index: 24 }
    ].each do |attrs|
      PokeLocationArea.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/location-area", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/location-area/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/location-area/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/location-area", params: { q: "oreburgh-mine" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 2, payload["count"]
  end

  test "show supports retrieval by id and name" do
    location_area = PokeLocationArea.find_by!(name: "oreburgh-mine-1f")

    get "/api/v2/location-area/#{location_area.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal location_area.id, payload["id"]
    assert_equal "oreburgh-mine-1f", payload["name"]
    assert_equal 6, payload["location_id"]
    assert_equal 6, payload["game_index"]

    get "/api/v2/location-area/OREBURGH-MINE-1F"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/location-area/oreburgh-mine-1f"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    location_area = PokeLocationArea.find_by!(name: "oreburgh-mine-1f")

    get "/api/v2/location-area/"
    assert_response :success

    get "/api/v2/location-area/#{location_area.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/location-area", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/location-area", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    location_area = PokeLocationArea.find_by!(name: "oreburgh-mine-1f")
    get "/api/v2/location-area/#{location_area.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/location-area/#{location_area.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/location-area/%2A%2A"

    assert_response :not_found
  end
end
