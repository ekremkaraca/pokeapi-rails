require "test_helper"

class Api::V2::NatureControllerTest < ActionDispatch::IntegrationTest
  setup do
    PokeNature.delete_all

    [
      { name: "hardy", decreased_stat_id: 2, increased_stat_id: 2, hates_flavor_id: 1, likes_flavor_id: 1, game_index: 0 },
      { name: "bold", decreased_stat_id: 2, increased_stat_id: 3, hates_flavor_id: 1, likes_flavor_id: 2, game_index: 1 },
      { name: "modest", decreased_stat_id: 2, increased_stat_id: 4, hates_flavor_id: 1, likes_flavor_id: 3, game_index: 2 },
      { name: "calm", decreased_stat_id: 2, increased_stat_id: 5, hates_flavor_id: 1, likes_flavor_id: 4, game_index: 3 },
      { name: "timid", decreased_stat_id: 2, increased_stat_id: 6, hates_flavor_id: 1, likes_flavor_id: 5, game_index: 4 }
    ].each do |attrs|
      PokeNature.create!(attrs)
    end
  end

  test "list returns paginated summary data" do
    get "/api/v2/nature", params: { limit: 2, offset: 1 }

    assert_response :success
    payload = JSON.parse(response.body)

    assert_equal 5, payload["count"]
    assert_equal 2, payload["results"].length
    assert_not_nil payload["next"]
    assert_not_nil payload["previous"]
    assert_equal %w[name url], payload["results"].first.keys.sort
    assert_match(%r{/api/v2/nature/\d+/$}, payload["results"].first["url"])
    refute_match(%r{/api/v2/nature/\d+//$}, payload["results"].first["url"])
  end

  test "list supports q filter" do
    get "/api/v2/nature", params: { q: "mod" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal 1, payload["count"]
    assert_equal [ "modest" ], payload["results"].map { |record| record["name"] }
  end

  test "show supports retrieval by id and name" do
    nature = PokeNature.find_by!(name: "hardy")

    get "/api/v2/nature/#{nature.id}"
    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal nature.id, payload["id"]
    assert_equal "hardy", payload["name"]
    assert_equal 2, payload["decreased_stat_id"]
    assert_equal 2, payload["increased_stat_id"]
    assert_equal 1, payload["hates_flavor_id"]
    assert_equal 1, payload["likes_flavor_id"]
    assert_equal 0, payload["game_index"]

    get "/api/v2/nature/HARDY"
    assert_response :success
  end

test "show query count stays within budget" do
  query_count = capture_select_query_count do
    get "/api/v2/nature/hardy"
    assert_response :success
  end

  assert_operator query_count, :<=, 14
end

  test "list and show accept trailing slash" do
    nature = PokeNature.find_by!(name: "hardy")

    get "/api/v2/nature/"
    assert_response :success

    get "/api/v2/nature/#{nature.id}/"
    assert_response :success
  end

  test "list supports conditional get with etag" do
    get "/api/v2/nature", params: { limit: 2, offset: 0 }
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/nature", params: { limit: 2, offset: 0 }, headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show supports conditional get with etag" do
    nature = PokeNature.find_by!(name: "hardy")
    get "/api/v2/nature/#{nature.id}"
    assert_response :success
    assert_observability_headers

    etag = response.headers["ETag"]
    assert etag.present?

    get "/api/v2/nature/#{nature.id}", headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_observability_headers
    assert_equal "", response.body
  end

  test "show returns 404 for invalid lookup token" do
    get "/api/v2/nature/%2A%2A"

    assert_response :not_found
  end
end
