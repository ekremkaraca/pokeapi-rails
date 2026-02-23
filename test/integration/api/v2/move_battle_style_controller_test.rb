require "test_helper"

class Api::V2::MoveBattleStyleControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeMoveBattleStyle.delete_all

    [
      "attack",
      "defense",
      "support"
    ].each do |name|
      PokeMoveBattleStyle.create!(name: name)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/move-battle-style", params: { limit: 1, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 3, payload["count"]
    assert_equal 1, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/move-battle-style/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/move-battle-style/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/move-battle-style", params: { q: "sup" }

    assert_response :success
    payload = JSON.parse(response.body)
    names = payload["results"].map { |record| record["name"] }

    assert_equal 1, payload["count"]
    assert_equal [ "support" ], names
  end

  test "show supports retrieval by id and name" do
    style = PokeMoveBattleStyle.find_by!(name: "attack")

    get "/api/v2/move-battle-style/#{style.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal style.id, payload["id"]
    assert_equal "attack", payload["name"]

    get "/api/v2/move-battle-style/ATTACK"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/move-battle-style/attack"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    style = PokeMoveBattleStyle.find_by!(name: "attack")

    get "/api/v2/move-battle-style/"
    assert_response :success

    get "/api/v2/move-battle-style/#{style.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/move-battle-style", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/move-battle-style", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    style = PokeMoveBattleStyle.find_by!(name: "attack")
    get "/api/v2/move-battle-style/#{style.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/move-battle-style/#{style.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/move-battle-style/%2A%2A"

    assert_response :not_found
  end
end
