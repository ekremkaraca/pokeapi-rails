require "test_helper"

class Api::V2::EncounterMethodControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeEncounterMethod.delete_all

    [
      { name: "walk", sort_order: 1 },
      { name: "old-rod", sort_order: 10 },
      { name: "good-rod", sort_order: 11 },
      { name: "super-rod", sort_order: 12 },
      { name: "surf", sort_order: 14 }
    ].each do |attrs|
      PokeEncounterMethod.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/encounter-method", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/encounter-method/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/encounter-method/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/encounter-method", params: { q: "rod" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 3, payload["count"]
  end

  test "show supports retrieval by id and name" do
    method = PokeEncounterMethod.find_by!(name: "walk")

    get "/api/v2/encounter-method/#{method.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal method.id, payload["id"]
    assert_equal "walk", payload["name"]
    assert_equal 1, payload["order"]

    get "/api/v2/encounter-method/WALK"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/encounter-method/walk"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    method = PokeEncounterMethod.find_by!(name: "walk")

    get "/api/v2/encounter-method/"
    assert_response :success

    get "/api/v2/encounter-method/#{method.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/encounter-method", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/encounter-method", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    method = PokeEncounterMethod.find_by!(name: "walk")
    get "/api/v2/encounter-method/#{method.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/encounter-method/#{method.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/encounter-method/%2A%2A"

    assert_response :not_found
  end
end
